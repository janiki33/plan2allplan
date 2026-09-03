<#
.SYNOPSIS
    Zwei-Wege-Abgleich zwischen dem plan2allplan-Repository und den lokalen
    Allplan-Benutzerordnern (Library / PythonPartsScripts).

.DESCRIPTION
    Ablauf (Auftrag Abschnitt 2.3):
      1. git pull origin <Branch>
      2. Allplan-relevante Dateien (.py, .pyp, .png, .incl) aus
             allplan_adapter\Library            -> <AllplanUsr>\Library
             allplan_adapter\PythonPartsScripts -> <AllplanUsr>\PythonPartsScripts
         spiegeln. Der Rueckweg gilt genauso: Dateien, die in den Allplan-Ordnern
         (nur innerhalb der gespiegelten Unterordner, z. B. Library\Plan2Allplan)
         geaendert oder neu angelegt wurden, werden ins Repo zurueckkopiert.
         Unterscheiden sich beide Seiten, gewinnt die neuere Datei; der Fall wird
         als KONFLIKT protokolliert (mit beiden Zeitstempeln).
      3. git add -A, Commit mit Zeitstempel, git push origin <Branch>
      4. Zusammenfassung: was kopiert, was gepusht.

    Pfadlogik und Ablauf nach docs\reference_sync_script.ps1 (SlabReinforcement-
    Projekt): <AllplanUsr> = Wurzel des Allplan-Benutzerverzeichnisses, darunter
    "Library" (fuer .pyp) und "PythonPartsScripts" (fuer .py). Diese beiden Baeume
    sind laut Allplan-Handbuch (Key components -> File locations) getrennt;
    Allplan sucht in der Reihenfolge Prj -> Std -> Usr.

    Wird bei jeder Aenderung an Skripten __pycache__ geleert, damit Allplan die
    Module wirklich neu laedt.

.PARAMETER AllplanUsr
    Wurzel des Allplan-Benutzerverzeichnisses (Allmenu -> Service -> File explorer
    -> "My own CAD documents"). Standard aus dem Referenzskript.

.PARAMETER Branch
    Git-Branch, der gezogen und gepusht wird. Ohne Angabe: der aktuell
    ausgecheckte Branch des Repos (waehrend der Entwicklung der Arbeitsbranch,
    spaeter main).

.PARAMETER DryRun
    Nur anzeigen, was passieren wuerde; nichts kopieren, nichts committen.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\sync_allplan.ps1
.EXAMPLE
    .\sync_allplan.ps1 -AllplanUsr 'C:\Users\me\Documents\Nemetschek\Allplan\2026\Usr\Local'
#>

[CmdletBinding()]
param(
    [string] $AllplanUsr = 'J:\Allplan\Usr\Janosch',
    [string] $Branch     = '',
    [switch] $DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RepoRoot   = Split-Path -Parent $PSCommandPath
$AdapterDir = Join-Path $RepoRoot 'allplan_adapter'

# Gespiegelte Baeume: Pfad im Repo (relativ zu allplan_adapter) -> Pfad relativ zu $AllplanUsr
$SyncDirs = @(
    @{ Source = 'Library';            Target = 'Library' }
    @{ Source = 'PythonPartsScripts'; Target = 'PythonPartsScripts' }
)

# Nur diese Dateitypen werden gespiegelt.
$SyncedExtensions = @('.py', '.pyp', '.png', '.incl', '.xml')

# Bekannte Grenze: Loeschungen werden nicht propagiert. Eine im Repo geloeschte
# Datei kommt beim naechsten Lauf aus dem Allplan-Ordner zurueck (und umgekehrt);
# zum endgueltigen Entfernen die Datei auf beiden Seiten loeschen.

$Summary = [ordered]@{
    ToAllplan = New-Object System.Collections.Generic.List[string]
    ToRepo    = New-Object System.Collections.Generic.List[string]
    Conflicts = New-Object System.Collections.Generic.List[string]
    Pushed    = $false
    Commit    = ''
}


function Write-Log {
    param(
        [Parameter(Mandatory)][string] $Message,
        [ValidateSet('INFO', 'CHANGE', 'WARN', 'ERROR')][string] $Level = 'INFO'
    )
    $line = '{0} [{1}] {2}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Level, $Message
    switch ($Level) {
        'CHANGE' { Write-Host $line -ForegroundColor Green }
        'WARN'   { Write-Host $line -ForegroundColor Yellow }
        'ERROR'  { Write-Host $line -ForegroundColor Red }
        default  { Write-Host $line }
    }
}


function Invoke-Git {
    param([Parameter(Mandatory)][string[]] $Arguments)
    Write-Log ('git ' + ($Arguments -join ' '))
    if ($DryRun -and ($Arguments[0] -in @('add', 'commit', 'push'))) { return '' }
    # git schreibt Fortschritt routinemaessig nach stderr. Mit
    # $ErrorActionPreference = 'Stop' wuerde PowerShell 5.1 jede stderr-Zeile
    # als NativeCommandError werfen, bevor $LASTEXITCODE geprueft ist - deshalb
    # nur fuer den Aufruf auf 'Continue' schalten und stderr-Records zu Text machen.
    $prevEap = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = & git -C $RepoRoot @Arguments 2>&1 | ForEach-Object { "$_" }
        $exit = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $prevEap
    }
    $text = ($output | Out-String).Trim()
    if ($exit -ne 0) {
        throw "git $($Arguments[0]) fehlgeschlagen (Exit $exit): $text"
    }
    if ($text) { Write-Host $text }
    return $text
}


function Get-FileHashHex {
    param([Parameter(Mandatory)][string] $Path)
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA1).Hash
}


function Copy-Synced {
    param(
        [Parameter(Mandatory)][string] $From,
        [Parameter(Mandatory)][string] $To
    )
    $dir = Split-Path -Parent $To
    if (-not $DryRun) {
        if (-not (Test-Path -LiteralPath $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
        Copy-Item -LiteralPath $From -Destination $To -Force
    }
}


function Clear-PyCache {
    param([Parameter(Mandatory)][string] $Directory)
    if (-not (Test-Path -LiteralPath $Directory)) { return }
    Get-ChildItem -LiteralPath $Directory -Directory -Recurse -Filter '__pycache__' -ErrorAction SilentlyContinue |
        ForEach-Object {
            if (-not $DryRun) { Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction SilentlyContinue }
            Write-Log "__pycache__ geleert: $($_.FullName)"
        }
}


function Get-SyncedFiles {
    <# Alle Dateien mit erlaubter Endung unterhalb eines Wurzelordners, als
       Hashtable relativer Pfad -> FileInfo. #>
    param([Parameter(Mandatory)][string] $Root)
    $map = @{}
    if (-not (Test-Path -LiteralPath $Root)) { return $map }
    Get-ChildItem -LiteralPath $Root -File -Recurse | Where-Object {
        $SyncedExtensions -contains $_.Extension -and $_.FullName -notmatch '\\__pycache__\\'
    } | ForEach-Object {
        $rel = $_.FullName.Substring($Root.Length).TrimStart('\')
        $map[$rel] = $_
    }
    return $map
}


function Sync-Tree {
    param([Parameter(Mandatory)][hashtable] $Entry)

    $repoRootDir    = Join-Path $AdapterDir $Entry.Source
    $allplanRootDir = Join-Path $AllplanUsr $Entry.Target

    $repoFiles = Get-SyncedFiles -Root $repoRootDir

    # Rueckweg nur fuer Unterordner, die das Repo kennt (z. B. Library\Plan2Allplan),
    # damit fremde PythonParts im Allplan-Ordner nicht ins Repo wandern.
    $ownedSubdirs = @($repoFiles.Keys | ForEach-Object { ($_ -split '\\')[0] } | Sort-Object -Unique)

    $allplanFiles = @{}
    foreach ($sub in $ownedSubdirs) {
        $subRoot = Join-Path $allplanRootDir $sub
        $found = Get-SyncedFiles -Root $subRoot
        foreach ($k in $found.Keys) { $allplanFiles[(Join-Path $sub $k)] = $found[$k] }
    }

    $changedTarget = $false
    $allKeys = @($repoFiles.Keys + $allplanFiles.Keys | Sort-Object -Unique)

    foreach ($rel in $allKeys) {
        $inRepo    = $repoFiles.ContainsKey($rel)
        $inAllplan = $allplanFiles.ContainsKey($rel)
        $repoPath    = Join-Path $repoRootDir $rel
        $allplanPath = Join-Path $allplanRootDir $rel
        $label = "$($Entry.Target)\$rel"

        if ($inRepo -and -not $inAllplan) {
            Copy-Synced -From $repoPath -To $allplanPath
            Write-Log "-> Allplan (neu): $label" -Level CHANGE
            $Summary.ToAllplan.Add($label); $changedTarget = $true
            continue
        }
        if ($inAllplan -and -not $inRepo) {
            Copy-Synced -From $allplanPath -To $repoPath
            Write-Log "<- Repo (neu aus Allplan): $label" -Level CHANGE
            $Summary.ToRepo.Add($label)
            continue
        }

        if ((Get-FileHashHex $repoPath) -eq (Get-FileHashHex $allplanPath)) {
            Write-Log "unveraendert: $label"
            continue
        }

        # Beide vorhanden, Inhalt verschieden: neuere Datei gewinnt, Konflikt anzeigen.
        $repoTime    = $repoFiles[$rel].LastWriteTime
        $allplanTime = $allplanFiles[$rel].LastWriteTime
        $msg = "KONFLIKT $label  Repo: $($repoTime.ToString('yyyy-MM-dd HH:mm:ss'))  Allplan: $($allplanTime.ToString('yyyy-MM-dd HH:mm:ss'))"
        if ($allplanTime -gt $repoTime) {
            Copy-Synced -From $allplanPath -To $repoPath
            Write-Log "$msg  => Allplan-Fassung uebernommen (neuer)" -Level WARN
            $Summary.ToRepo.Add($label)
        }
        else {
            Copy-Synced -From $repoPath -To $allplanPath
            Write-Log "$msg  => Repo-Fassung uebernommen (neuer)" -Level WARN
            $Summary.ToAllplan.Add($label); $changedTarget = $true
        }
        $Summary.Conflicts.Add($msg)
    }

    if ($changedTarget) { Clear-PyCache -Directory $allplanRootDir }
}


# --- Ablauf ---------------------------------------------------------------

if (-not (Test-Path -LiteralPath $AllplanUsr)) {
    Write-Log "Allplan-Benutzerverzeichnis nicht erreichbar: $AllplanUsr (Netzlaufwerk verbunden? Parameter -AllplanUsr)" -Level ERROR
    exit 2
}
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Log 'git wurde nicht gefunden (PATH).' -Level ERROR
    exit 2
}

if (-not $Branch) {
    $Branch = Invoke-Git @('rev-parse', '--abbrev-ref', 'HEAD')
    if (-not $Branch -or $Branch -eq 'HEAD') {
        Write-Log 'Kein Branch ausgecheckt (detached HEAD) - bitte -Branch angeben.' -Level ERROR
        exit 2
    }
}

Write-Log "Abgleich $RepoRoot@$Branch <-> $AllplanUsr $(if ($DryRun) {'(DryRun)'})"

# 1. Neuesten Stand holen
Invoke-Git @('pull', 'origin', $Branch) | Out-Null

# 2. Beide Richtungen spiegeln
foreach ($entry in $SyncDirs) { Sync-Tree -Entry $entry }

# 3. Aenderungen committen und pushen
$status = Invoke-Git @('status', '--porcelain')
if ($status) {
    $stamp = Get-Date -Format 'yyyy-MM-dd HH:mm'
    Invoke-Git @('add', '-A') | Out-Null
    Invoke-Git @('commit', '-m', "sync_allplan: $stamp") | Out-Null
    Invoke-Git @('push', 'origin', $Branch) | Out-Null
    $Summary.Pushed = -not $DryRun
    $Summary.Commit = "sync_allplan: $stamp"
}
else {
    Write-Log 'Repo unveraendert - kein Commit noetig.'
}

# 4. Zusammenfassung
Write-Host ''
Write-Host '===== Zusammenfassung =====' -ForegroundColor Cyan
Write-Host ("Repo -> Allplan : {0} Datei(en)" -f $Summary.ToAllplan.Count)
$Summary.ToAllplan | ForEach-Object { Write-Host "    $_" }
Write-Host ("Allplan -> Repo : {0} Datei(en)" -f $Summary.ToRepo.Count)
$Summary.ToRepo | ForEach-Object { Write-Host "    $_" }
if ($Summary.Conflicts.Count -gt 0) {
    Write-Host ("Konflikte       : {0}" -f $Summary.Conflicts.Count) -ForegroundColor Yellow
    $Summary.Conflicts | ForEach-Object { Write-Host "    $_" -ForegroundColor Yellow }
}
if ($Summary.Pushed) { Write-Host "Gepusht         : '$($Summary.Commit)' nach origin/$Branch" -ForegroundColor Green }
else                 { Write-Host 'Gepusht         : nichts' }
if ($Summary.ToAllplan.Count -gt 0) { Write-Host 'Hinweis: Allplan neu starten, damit geaenderte Skripte geladen werden.' }
