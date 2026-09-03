# Testprotokoll E0 – Sync-Skript und Dummy-PythonPart

**Ziel:** `sync_allplan.ps1` läuft per Doppelklick/`.\sync_allplan.ps1`, das Dummy-PythonPart erscheint in Allplan 2026 und funktioniert, und der Rückweg (Allplan → Repo → Push) funktioniert.

**Voraussetzungen**
- Repo lokal geklont (`git clone https://github.com/janiki33/plan2allplan`) und der Arbeitsbranch
  ausgecheckt (`git checkout claude/plan2allplan-bim-automation-0hcz95`; nach dem Merge: `main`).
  Das Skript nimmt ohne `-Branch` den aktuell ausgecheckten Branch.
- Allplan-Benutzerverzeichnis erreichbar (Standard `J:\Allplan\Usr\Janosch`, sonst Parameter `-AllplanUsr`).
- `git` im PATH, Push-Berechtigung vorhanden.

| # | Schritt | Erwartetes Ergebnis | Ergebnis (bestanden / nicht) |
|---|---------|--------------------|------------------------------|
| 1 | PowerShell im Repo-Root öffnen: `.\sync_allplan.ps1` (ggf. `powershell -ExecutionPolicy Bypass -File .\sync_allplan.ps1`) | Skript läuft ohne rote Fehlerzeile durch. Log zeigt `git pull`, dann `-> Allplan (neu): Library\Plan2Allplan\Plan2Allplan.pyp`, `-> Allplan (neu): PythonPartsScripts\Plan2Allplan\__init__.py`, `... \dummy.py`. Zusammenfassung: «Repo -> Allplan : 3 Datei(en)», «Gepusht : nichts» (Repo unverändert). | |
| 2 | Dateien prüfen: `<AllplanUsr>\Library\Plan2Allplan\Plan2Allplan.pyp` und `<AllplanUsr>\PythonPartsScripts\Plan2Allplan\{__init__.py (leer), dummy.py}` | Alle drei Dateien vorhanden. | |
| 3 | Allplan 2026 starten (oder neu starten), Bibliothek → **Privat** (Usr) → Plan2Allplan → «Plan2Allplan (E0 Dummy)» starten | Palette mit Parameter «Test line length» = 1000 erscheint; keine Fehlermeldung im Trace-Fenster. | |
| 4 | PythonPart absetzen (Klick ins Teilbild) | Eine horizontale 2D-Linie mit Länge 1.000 m (1000 mm) wird erzeugt. Messpunkt: Länge messen → Soll 1.000 m. | |
| 5 | Rückweg testen: In `<AllplanUsr>\Library\Plan2Allplan\Plan2Allplan.pyp` den Wert `<Value>1000.</Value>` auf `<Value>2000.</Value>` ändern und speichern. `.\sync_allplan.ps1` erneut ausführen. | Log zeigt `KONFLIKT Library\Plan2Allplan\Plan2Allplan.pyp ... => Allplan-Fassung uebernommen (neuer)`, danach `git commit` «sync_allplan: <Zeitstempel>» und `git push`. Zusammenfassung: «Allplan -> Repo : 1 Datei(en)», «Gepusht : 'sync_allplan: …'». | |
| 6 | Auf GitHub prüfen: letzter Commit auf dem Branch heisst `sync_allplan: <Zeitstempel>` und enthält die geänderte `.pyp` mit `2000.` | Commit sichtbar, Diff zeigt 1000. → 2000. | |
| 7 | (Aufräumen) Wert zurück auf `1000.` setzen, Skript erneut laufen lassen | Wieder Konflikt → Allplan-Fassung, Commit, Push. | |

**Rückmeldung an den Agenten:** bitte pro Zeile «bestanden» oder die wörtliche Fehlermeldung / Abweichung eintragen und zurückgeben. Falls Schritt 3 keine Bibliotheks-Einträge zeigt: Pfad aus Allmenu → Service → File explorer → «My own CAD documents» nennen.
