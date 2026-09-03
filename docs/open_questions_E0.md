# Offene Fragen nach Etappe 0 (gesammelt, mit Vorschlag)

Quellen: docs/research_allplan.md (O-1…O-10), docs/research_ifc.md, docs/research_extraction.md.
Bitte pro Frage antworten (Vorschlag übernehmen = «ok»). Blockierende Fragen zuerst.

## A. Entscheidungen, die Etappe 1/3/5 blockieren

| # | Frage | Vorschlag |
|---|-------|-----------|
| F1 | **Brüstung/Sturz**: Umsetzung als Wandsegmente mit gemischter Höhenanbindung (`PlaneReferences`: unten Ebene, oben Absolutkote bzw. umgekehrt) – nicht als Unterzug (`BeamElement`), nicht als 3D-Solid. | Weg 1 (Wandsegmente) bestätigen. |
| F2 | **Bauwerksstruktur ist per PythonPart-API nicht lesbar** (kein Storey/Level-Objekt in der 2026-Referenz; lesbar sind nur die Default-Ebenen des *aktiven Teilbilds* und Teilbildnummern/-namen). Damit kann E5.0 «Ebenen-Export» nicht wie geplant die ganze Geschossliste ausgeben. | Projektkonfiguration `project_levels.json` (Geschoss → Teilbildnummer, Name der OK/UK-Ebene, Höhen) wird **einmalig von dir** angelegt; das PythonPart liest dazu pro aktivem Teilbild die Default-Ebenen aus und prüft/ergänzt die Datei (Plausibilität statt Vollexport). |
| F3 | **Teilbildwechsel**: Soll das PythonPart pro Geschoss das Ziel-Teilbild selbst aktiv setzen (`DrawingFileService.LoadFile`) oder startest du den Lauf je Geschoss mit vorher aktiviertem Teilbild? | Ein Lauf pro Geschoss, Teilbild vorher manuell aktiv (risikoarm); Automatik später als Option. |
| F4 | **Liftgrube**: (a) eigene tieferliegende Fundamentplatte + Grubenwände mit eigener Höhenanbindung, oder (b) Rücksprung (`eRecess`) in der Bodenplatte? | (a) – entspricht Abschnitt 3.6 des Auftrags und liefert saubere Rohbau-Massen. |
| F5 | **DWG-Eingang**: ezdxf liest kein DWG; nötig ist der kostenlose ODA File Converter (`ezdxf.addons.odafc`). Ist er auf deinem Rechner installiert bzw. darf er installiert werden? Alternativ: Architekten liefern DXF. | ODA File Converter installieren; Standardpfad wird erkannt, sonst Parameter. |
| F6 | **Liegen DWG oder nur PDF vor?** Und sind die PDFs Vektor-PDFs mit echtem Text (Koten lesbar) oder gerenderte Kurven/Scans? Bitte 1–2 echte Beispielpläne in `input/` ablegen (werden nicht committet). | Primärweg DWG/DXF; PDF-Vektor als Zweitweg; Raster nur Notweg. |

## B. Fachliche Festlegungen (Vorschlag reicht, wenn du nichts anderes willst)

| # | Frage | Vorschlag |
|---|-------|-----------|
| F7 | **Ablageort** für Sync: `Usr\<Benutzer>` (nur du) oder `Std` (büroweit)? Referenzskript nutzt `J:\Allplan\Usr\Janosch`. | `J:\Allplan\Usr\Janosch` (wie Referenz), Parameter `-AllplanUsr` für anderes Ziel. |
| F8 | **Materialwerte** (`ArchBaseProperties.Material` ist freier Text): Welche Schreibweise? | `Beton`, `Mauerwerk`, `Kalksandstein`, `Magerbeton`, `Dämmung` (Büro-Katalog später mappbar). |
| F9 | **Attribut «Brüstung»/«Sturz»**: Gibt es im Büro ein Benutzerattribut (Name/Nummer)? Sonst legt das Werkzeug beim ersten Lauf eines an. | Neues Benutzerattribut `Plan2Allplan_Rolle` anlegen lassen, zusätzlich Bauteilname (`Name`, Attribut 498) = «Brüstung»/«Sturz». |
| F10 | **Layer-Konventionen**: Halten sich die liefernden Büros an SIA-2014-Layer oder Büro-eigene Namen? Welche CAD-Software (AutoCAD/ArchiCAD/Vectorworks/Allplan)? Soll der SIA-2014-Volltext (kostenpflichtig) beschafft werden? | Lookup-Tabelle aus öffentlichen kantonalen Richtlinien starten, an deinen echten Plänen kalibrieren; SIA-Volltext nicht nötig. |
| F11 | **Massstab/Kotenblöcke**: Steht der Massstab maschinenlesbar im Plankopf? Gibt es einen Standard-Höhenkotenblock? | Massstab aus `$INSUNITS`/Bemassung ableiten, sonst Rückfrage im CLI; Koten-Text-Regex `[+±-]?\d{1,3}\.\d{2}`. |
| F12 | **IFC-Einheit**: Millimeter (Allplan-intern) oder Meter? | Millimeter, weil Allplan intern in mm rechnet; Test im Protokoll E4. |

## C. Am Windows-Rechner zu verifizieren (kommt als Messpunkt in die Protokolle E5.x; keine Antwort jetzt nötig)

- Semantik der Enums `PlaneReferenceDependency.eBottomPlane/eTopPlane/eAbsElevation` (Doku nennt nur Namen) – Testwand E5.1.
- `GeneralOpeningProperties` mit `Depth = 0` = durchgehend? – E5.5.
- Slab-Tier-Index 0- oder 1-basiert – E5.3.
- Ob Allplan 2026 beim IFC-Import Geschosse automatisch anlegt und ob eine Axis-Representation für Wände nötig ist – E4.
- Falls die Stubs unter `C:\Program Files\Allplan\Allplan 2026\Prg\PythonPartsFramework\` liegen: bitte den Ordner `...\PythonPartsFramework\` und `...\PythonParts-site-packages\` einmal auflisten (`dir /s *.pyi > stubs.txt`) und die Datei ins Repo unter `docs/stubs_listing.txt` legen – damit können Signaturen künftig lokal belegt werden.
