# Research: Extraktion aus Architektenplänen (DWG/DXF/PDF/Raster)

Stand: 2026-09-03. Installierte Bibliotheken (verifiziert in dieser Session):
`ezdxf==1.4.4`, `pymupdf==1.28.2` (Modulname `fitz`, Alias `pymupdf`, `fitz` als deprecated markiert),
`opencv-python-headless==5.0.0`, `shapely==2.1.2`, `numpy`.
Alle Aussagen sind mit Quelle belegt; Detail-Signaturen stehen in `docs/evidence_extraction.md`.

---

## A. DWG vs. DXF mit ezdxf

**Antwort: ezdxf kann DWG nicht nativ lesen.** ezdxf ist ein reiner DXF-Parser. Für DWG bietet es das
Add-on `ezdxf.addons.odafc`, das den externen, kostenlosen **ODA File Converter** (von der Open Design
Alliance) per Subprozess aufruft: die DWG wird zunächst vom Converter nach DXF gewandelt und dann von
ezdxf gelesen (bzw. umgekehrt beim Schreiben).

Funktionen (Quelle: https://ezdxf.readthedocs.io/en/stable/addons/odafc.html, Signaturen zusätzlich aus
`ezdxf/addons/odafc.py` verifiziert):
```python
from ezdxf.addons import odafc
doc = odafc.readfile('my.dwg')          # -> ezdxf.Drawing, wie ezdxf.readfile()
odafc.export_dwg(doc, 'my_R2018.dwg', version='R2018')
```
Signaturen:
- `odafc.readfile(filename, version=None, *, audit=False) -> Drawing`
- `odafc.export_dwg(doc, filename, version=None, *, audit=False, replace=False) -> None`
- `odafc.is_installed() -> bool` — prüft unter Windows `os.path.exists(get_win_exec_path())`,
  unter Linux/macOS `shutil.which("ODAFileConverter")` bzw. den konfigurierten `unix_exec_path`.

**Pfadkonfiguration**: über die ezdxf-Konfigurationsdatei (Abschnitt `[odafc-addon]`, Schlüssel
`win_exec_path` / `unix_exec_path`) oder `ezdxf.options`. Verifiziert: der ausgelesene Default-Windows-Pfad
lautet `C:\Program Files\ODA\ODAFileConverter\ODAFileConverter.exe` (`ezdxf.options.get("odafc-addon",
"win_exec_path")` in dieser Session ausgeführt).

**Plattformen/Versionen** (Quelle: ezdxf-Doku odafc.html): Windows XP/7+, Linux (RPM/DEB, 32/64-bit),
macOS. Unterstützte DWG-Formatversionen: R12…R2018 (AC1009…AC1032).

**Alternative reine Python-Wege**: Es gibt **keinen** verlässlichen reinen-Python-DWG-Parser, der in der
vorgegebenen Bibliotheksliste enthalten ist oder empfohlen werden kann; DWG ist ein proprietäres
Binärformat von Autodesk, dessen vollständige Spezifikation nicht offen dokumentiert ist. `ezdxf` selbst
verweist ausschliesslich auf odafc/ODA File Converter für DWG. (Andere Bibliotheken wie `libredwg` existieren,
sind aber nicht in der vorgegebenen Werkzeugliste und wurden daher nicht weiter untersucht – **offene
Frage**, falls DWG-Support ohne odafc gefordert wird.)

**Konsequenz für den Auftraggeber**: Wenn Pläne als DWG vorliegen, **muss der ODA File Converter auf der
Zielmaschine installiert sein** (Windows: Standard-Installationspfad wie oben, sonst Pfad konfigurieren).
Ohne ODA File Converter kann das Werkzeug nur DXF- oder PDF-Eingaben verarbeiten. Da laut Auftrag die
Zielumgebung ein Windows-Arbeitsplatz (Allplan) ist, ist eine Windows-Installation des Converters
realistisch, muss aber beim Auftraggeber bestätigt/veranlasst werden.

**Stolperstein**: `odafc` ruft den Converter als **Subprozess** auf (Batch-Verarbeitung über ein
Verzeichnis) – das bedeutet Lizenz-/Installationsabhängigkeit ausserhalb von Python, keine reine
pip-Installation, und der Aufruf ist langsam (Prozessstart) im Vergleich zu direktem DXF-Parsing.

---

## B. DXF lesen mit ezdxf

**Kernfunktionen** (alle per `inspect.signature` an der installierten Bibliothek verifiziert, siehe
Evidence-Tabelle):
```python
doc = ezdxf.readfile(filename, encoding=None, errors='surrogateescape')  # -> Drawing
msp = doc.modelspace()          # -> Modelspace (Iterable von DXFGraphic)
doc.layers                       # -> LayerTable (iterierbar, Layer.dxf.name)
doc.header.get('$INSUNITS')      # -> int (Einheiten-Code)
```

**Entity-Typen**: Im Probe-Skript (siehe unten) wurden `LWPOLYLINE` und `TEXT` real erzeugt, gespeichert
und wieder eingelesen; Layer- und Geometriezugriff funktionierte wie erwartet
(`e.dxftype()`, `e.dxf.layer`, `e.get_points("xy")`, `e.dxf.text`, `e.dxf.insert`).
Weitere Standard-Entity-Typen (aus der ezdxf-Klassenhierarchie, Modulpfad `ezdxf/entities/`, nicht alle
im Probe-Skript einzeln getestet, aber Klassen sind Teil der installierten Bibliothek und über
`e.dxftype()` unterscheidbar): `LINE`, `LWPOLYLINE`, `POLYLINE` (`Polyline`, mit Bulge, siehe J),
`ARC`, `CIRCLE`, `HATCH`, `TEXT`, `MTEXT`, `DIMENSION` (Unterklassen `Aligned/Linear/Angular/Radius/...`),
`INSERT` (Blockreferenz).

**Blöcke auflösen**:
```python
for e in insert_entity.virtual_entities():   # liefert transformierte Kopien, Original bleibt im Block
    ...
insert_entity.explode(target_layout=msp)     # baut echte Entities in den Layout ein, ersetzt den INSERT
```
Signaturen: `Insert.virtual_entities(self, *, skipped_entity_callback=None, redraw_order=False) ->
Iterator[DXFGraphic]`; `Insert.explode(self, target_layout=None, *, redraw_order=False) -> EntityQuery`.
`virtual_entities()` ist die bevorzugte, nicht-destruktive Variante für reine Extraktion (kein Mutieren
der Zeichnung nötig).

**Einheiten**: `$INSUNITS` im Header (Standard-DXF-Variable) codiert die Einheit; verifiziert per
`ezdxf.units`: `units.M == 6`, `units.MM == 4`, `units.decode(6) == 'm'`. Modelspace-Einheiten und
Papierraum-Einheiten (`$PLINSUNITS`/Layout-Einstellung) können differieren — siehe Stolperstein J.

**Koordinaten/Extents**: `ezdxf.bbox.extents(entities, *, fast=False, cache=None) -> BoundingBox`
berechnet die Bounding Box über eine Menge Entities — nützlich, um den Massstab/Ursprung eines Plans zu
plausibilisieren.

**Paperspace vs. Modelspace**: `doc.modelspace()` liefert den Modellraum; Papierräume/Layouts werden über
`doc.layout(name)` bzw. `doc.layouts` angesprochen (Modul `ezdxf.layouts`, MRO `Modelspace → Layout →
BaseLayout → _AbstractLayout → CreatorInterface`, verifiziert per `inspect`). Da Architekturpläne i. d. R.
massstabsgerecht im Modelspace gezeichnet und über Viewports im Papierraum plotten, sollte der
Extraktor primär den **Modelspace** lesen; Viewports/Layout-Skalierung sind nur relevant, falls Geometrie
tatsächlich im Papierraum liegt (unüblich für reine CAD-Wandpläne, aber möglich bei importierten
Rahmen/Titelblöcken).

---

## C. DXF schreiben mit ezdxf (Fixture-Generator)

Zentrale API, alle Signaturen per `inspect.signature` an der installierten Bibliothek verifiziert:
```python
doc = ezdxf.new(dxfversion='AC1027', setup=False, units=6)   # AC1027 = DXF R2013, units=6 = Meter
doc.layers.add(name='A_WAND', color=1)
msp = doc.modelspace()
msp.add_line(start, end, dxfattribs=None)
msp.add_lwpolyline(points, format='xyseb', *, close=False, dxfattribs=None)
msp.add_circle(center, radius, dxfattribs=None)
msp.add_hatch(color=7, dxfattribs=None)                       # Pattern wird per hatch.set_pattern_fill() gesetzt
msp.add_text(text, *, height=None, rotation=None, dxfattribs=None)
msp.add_mtext(text, dxfattribs=None)
msp.add_linear_dim(base, p1, p2, location=None, text='<>', angle=0, ..., dimstyle='EZDXF', override=None,
                    dxfattribs=None)   # -> DimStyleOverride; .render() erzeugt sichtbare Geometrie
doc.saveas(filename, encoding=None, fmt='asc')
```
**Wichtig verifiziert per Probe**: `add_linear_dim(...)` erzeugt zunächst nur den Dimension-Block; die
sichtbaren Mass-/Hilfslinien entstehen erst nach `.render()` (im Probe-Skript getestet: nach `render()`
+ `saveas()` + erneutem `readfile()` liefert `DIMENSION.dxf.text == '<>'` (Platzhalter = automatischer
Messwert) und `get_measurement() == 5.0` für eine 5 m lange Bemassung — bestätigt, dass `dxf.text`
nur bei explizitem Override vom Default `'<>'` abweicht.

**Export als PDF/PNG (`ezdxf.addons.drawing`, matplotlib-Backend)**:
```python
from ezdxf.addons.drawing.matplotlib import qsave
qsave(msp, 'out.pdf')                 # oder 'out.png', dpi=..., bg=..., fg=...
```
Signatur (verifiziert): `qsave(layout, filename, *, bg=None, fg=None, dpi=300, backend='agg',
config=None, filter_func=None, size_inches=None) -> None`. Intern baut `qsave` `RenderContext` +
`MatplotlibBackend` + `Frontend` zusammen (alle Signaturen ebenfalls verifiziert, siehe Evidence-Tabelle).

**Grenze, per Probe verifiziert (wichtig für den Fixture-Generator!)**: Der `drawing`-Renderer stellt
**TEXT/MTEXT immer als gefüllte Vektor-Pfade (Glyph-Outlines) dar, nie als echten PDF-Text**. Die Enum
`ezdxf.addons.drawing.config.TextPolicy` kennt nur `FILLING` (Default), `OUTLINE`, `REPLACE_RECT`,
`REPLACE_FILL`, `IGNORE` — keine Option erzeugt extrahierbaren Text. Bestätigt durch Quelltext von
`MatplotlibBackend`: es gibt kein `draw_text()`-Backend-Callback, nur `draw_filled_paths()` (baut
`matplotlib.patches.PathPatch(..., fill=True)`). **Konsequenz**: Ein über `ezdxf.addons.drawing` erzeugtes
PDF ist für `pymupdf.get_text()`-Tests **nicht geeignet** — im Probe-Skript lieferte
`page.get_text("dict")["blocks"]` **0** Text-Blöcke, obwohl ein `TEXT`-Entity mit "+412.35" im DXF stand
und im PDF sichtbar gerendert wurde. Für Test-Fixtures, die Text-/Koten-Extraktion aus PDF prüfen sollen,
braucht es einen zweiten Pfad (z. B. echte Text-Objekte separat mit pymupdf `page.insert_text()` einfügen,
oder Reportlab-Overlay) — **offene Frage/Empfehlung an den Auftraggeber**, siehe unten.

Auch fehlende Abhängigkeiten wurden gefunden: `ezdxf.addons.drawing` importiert `PIL` (Pillow), das
**nicht** in der vorgegebenen Installationsliste steht; ebenso wird `matplotlib` benötigt, das ebenfalls
nicht vorinstalliert war. Für das Probe-Skript wurden beide Pakete nachinstalliert
(`pip install matplotlib pillow`) – **das muss für den produktiven Fixture-Generator als zusätzliche
Abhängigkeit eingeplant werden**.

---

## D. PDF-Vektorextraktion mit pymupdf

**`page.get_drawings(extended=False) -> list`** (Signatur + Docstring "Retrieve vector graphics."
verifiziert): liefert pro Pfad ein Dict mit u. a. `type` (`'f'`=fill, `'s'`=stroke, `'fs'`=beides),
`items` (Liste von Tupeln `('l', p1, p2)` für Linien, `('c', p1, p2, p3, p4)` für kubische Bézierkurven,
`('re', Rect, orientation)` für Rechtecke, `('qu', Quad)` für Quads), `color`, `fill`, `width`,
`closePath`, `layer`, `rect` (Bounding Box). Im Probe-Skript verifiziert: eine gerenderte DXF-`LWPOLYLINE`
erscheint als Drawing-Item vom Typ `'s'` mit `items=[('l', Point, Point)]`, `color=(1.0,0.0,0.0)` (Farbe
des DXF-Layers/-Colors 1 = Rot), `width=0.25`. Damit ist die Struktur für Linien-Extraktion aus
Vektor-PDFs bestätigt.

**`page.get_text("dict")` / `page.get_text("words")`**: Für Beschriftungen/Koten. Struktur:
`{"blocks": [{"type": 0, "lines": [{"spans": [{"text": ..., "bbox": [...]}]}]}]}` für Textblöcke
(`type==1` wäre Bild-Block). **Wichtig**: funktioniert nur bei echten PDF-Text-Objekten — bei aus
CAD-Software exportierten PDFs (AutoCAD/Allplan-PDF-Plot) ist Text i. d. R. als echter Text eingebettet
(im Gegensatz zum ezdxf-Matplotlib-Renderer, siehe Frage C), sollte also für reale Baupläne funktionieren.
Muss aber pro Quell-CAD-System verifiziert werden (**offene Frage**: welche CAD-Software/PDF-Exportpfad
nutzen die Architekturbüros tatsächlich – "PDF drucken" erzeugt meist echten Text, "PDF von
Rasterbild"/Scan nicht).

**Transformationsmatrix/Skalierung**: `fitz.Matrix(a,b,c,d,e,f)` (Signatur verifiziert) beschreibt eine
affine 2D-Transformation; `page.get_pixmap(matrix=...)` nimmt sie zur Auflösungssteuerung. Für die
Modellkoordinaten-Rückrechnung bei einem Planmassstab 1:50 muss der Massstabsfaktor separat aus
Plankopf/Titelblock oder einer bekannten Referenzlänge (z. B. Bemassung) abgeleitet werden — pymupdf
selbst kennt den "Architekturmassstab" nicht, nur PDF-Punkte (1/72 Zoll). D. h.: PDF-Koordinaten (Punkt)
→ Papier-mm (× 25.4/72) → Modell-mm (× Massstab, z. B. ×50 bei 1:50). **Offene Frage an den
Auftraggeber**: Ist der Massstab in den PDFs maschinenlesbar (Titelblock-Text, feste Konvention) oder
muss er interaktiv/heuristisch bestimmt werden (z. B. über bekannte Normmasse wie Türbreiten)?

**`page.get_pixmap(...)`**: liefert ein `Pixmap`-Rasterbild der Seite (für Fallback auf OpenCV-Pipeline
bei rein rasterbasierten PDFs, z. B. gescannte Pläne).

---

## E. Raster mit opencv

Verifiziert per Docstring der installierten Bibliothek (`opencv-python-headless==5.0.0`):
- `cv2.HoughLinesP(image, rho, theta, threshold[, lines[, minLineLength[, maxLineGap]]]) -> lines` —
  probabilistische Hough-Transformation für Liniensegmente auf einem 8-bit-Binärbild; Rückgabe
  `(x1,y1,x2,y2)` je Segment.
- `cv2.findContours(image, mode, method[, ...]) -> contours, hierarchy` — Konturerkennung auf Binärbild;
  ab dieser OpenCV-Version (5.0/4.14+) bei `RETR_LIST` ohne angeforderte Hierarchie ein neuer paralleler
  "TRUCO"-Algorithmus, sonst klassisch Suzuki85 (laut Docstring).
- `cv2.morphologyEx(src, op, kernel[, ...]) -> dst` — morphologische Operationen (Opening/Closing) zur
  Trennung/Verbindung paralleler Wandlinien vor der Konturerkennung.

**Skalierung**: analog zu D — aus bekanntem Plan-Massstab und Bild-DPI (`Pixel × 25.4/DPI × Massstab`)
lässt sich die Pixel→mm-Umrechnung ableiten; ohne verlässlichen Massstab/DPI-Metadaten im Rasterbild ist
keine masshaltige Extraktion möglich.

**Grenzen (fachliche Einschätzung, kein Bibliotheks-Fakt)**: Klassische CV-Pipelines (Hough/Konturen/
Morphologie) liefern rohe Geometrie (Linien, Blobs), aber **keine Semantik** (ist das eine Wand oder eine
Bemassungslinie? Ist der Kreis eine Stütze oder ein Möbelsymbol?). Für Semantik-Klassifikation bei
Rasterplänen ohne Layerinformation ist ein Vision-LLM (oder ein trainiertes CV-Modell, siehe Frage H)
sinnvoll — aber **nur für die Klassifikation/Beschriftung**, nicht für die geometrische Koordinatenermittlung:
LLM-Vision-Ausgaben sind nicht pixel-/masshaltig genau genug, um Wandachsen oder Türbreiten direkt als
Zahl zu übernehmen; die Geometrie muss aus der CV-Pipeline (oder besser: aus Vektordaten, DXF/PDF) kommen,
das LLM liefert höchstens Label/Klasse für einen bereits extrahierten geometrischen Kandidaten.

---

## F. Geometrie mit shapely

Signaturen verifiziert per `inspect.signature` (installierte Bibliothek):
- `LineString.buffer(self, distance, quad_segs=16, cap_style='round', join_style='round',
  mitre_limit=5.0, single_sided=False, **kwargs)` — z. B. `line.buffer(0.01, cap_style='flat')` um zwei
  parallele Kanten zu einem Polygon-Streifen zu verbinden bzw. Nähe-Cluster zu bilden.
- `shapely.ops.unary_union(geoms)` — verschmilzt mehrere (sich berührende/überlappende) Geometrien zu
  einer; nützlich um Wand-Segment-Puffer zusammenzuführen.
- `shapely.ops.polygonize(lines)` — baut aus einer Menge von (sich schneidenden) LineStrings geschlossene
  Polygone; einsetzbar, um aus zwei parallelen Wandkanten + Endkappen ein Wand-Rechteck oder aus einem
  Netz von Wandachsen die Raumpolygone (für Deckenkonturen) zu erzeugen.
- `Polygon(shell, holes=None)` — Polygon mit Löchern (laut Shapely-API; Konstruktor-Signatur ist in der
  installierten Version generisch `(*args, **kwargs)`, das `shell/holes`-Muster ist der dokumentierte
  öffentliche Shapely-API-Vertrag) — geeignet für Deckenkonturen mit Aussparungen/Liftgruben als Loch.
- `shapely.contains(a, b) -> bool` (bzw. vektorisiert) — Punkt-in-Polygon-Test für Host-Zuordnung (z. B.
  welches Fenster liegt in welcher Wand-Bounding-Box, welcher Raum enthält welche Stütze).

**Praktischer Ablauf Wandachse aus zwei Parallelen** (fachliche Ableitung, keine Bibliotheksfunktion
macht das automatisch): (1) Liniensegmente nach Winkel gruppieren (Toleranz), (2) je Gruppe nach
senkrechtem Abstand clustern (Kandidaten für "gleiche Wand, zwei Kanten"), (3) Mittelachse als Mittelwert
der beiden Parallelen, Wanddicke als deren Abstand, (4) `polygonize`/`buffer` zur Flächenbildung für
Kollisions-/Host-Tests.

**Stützen**: Rechtecke erkennbar über `LWPOLYLINE`/`HATCH`-Konturen mit 4 rechten Winkeln (oder direkt aus
CAD-Layer "STUETZE" + `Circle`/`LWPolyline`-Entity-Typ), Kreise direkt aus `CIRCLE`-Entities.

---

## G. Layer-Konventionen Schweizer Architekturbüros

**Offizielle Quelle**: SIA-Merkblatt **2014** "CAD-Datenaustausch – Layerstruktur und Layerschlüssel"
(https://shop.sia.ch/normenwerk/architekt/2014_2017_d/D/Product), kostenpflichtig, **Inhalt in dieser
Session nicht vollständig einsehbar** (nur Produktseite/Metadaten gefunden, kein Volltext) — das ist eine
**belegte Wissenslücke**, kein geratener Fakt. Verifiziert (per Websuche, Sekundärquellen) ist:
- Die Layercodierung ist an den **eBKP-H** (Elementkostengliederung Hochbau, herausgegeben vom **CRB**,
  Schweizerische Zentralstelle für Baurationalisierung) gekoppelt.
- Kantonale Hochbauämter veröffentlichen konkretisierende, teils frei zugängliche CAD-Richtlinien mit
  Layerlisten, z. B.:
  - Basel-Stadt: „CAD-Richtlinie SA" (PDF, https://media.bs.ch/original_file/bfdb4a6d5efde9cf350dcb0010a782b08625bd4a/cad-richtlinie-sa-version-4-3-okt24-2-3410.pdf)
    und „CAFM-Basis-Layerstruktur" (https://media.bs.ch/original_file/6ef7231b96d6e8a8e38bc1744f8f89668a46db36/layerstruktur.pdf)
  - Kanton Zug: HBA-Standard-CAD-Richtlinie (https://zg.ch/dam/jcr:0746cb70-776d-49d0-b128-9d103e7a340e/CAD_Richtlinie.pdf)
  - Kanton Solothurn: CAD-Richtlinie 4.2.1 (https://so.ch/fileadmin/internet/bjd/bjd-hba/04-Ueber-uns/Zusatzrubrik/CAD_Richtlinien_HBASO_4-2_1_Revision_20190703.pdf)
  - CAD-Exchange (Zürich, „Standardisierung des CAD-Datenaustauschs", cadexchange.ch) publiziert ein
    „CP0002 Layerstruktur Architektur"-Produktblatt.

  Diese PDFs wurden **nicht vollständig gelesen** (nur Titel/Metadaten aus der Websuche) — der konkrete
  Layer-Namensraum (z. B. exakte Buchstaben-/Zifferncodes) ist damit **nicht verifiziert** und wird hier
  bewusst **nicht als Faktum behauptet**. Für die konkrete Lookup-Tabelle wird deshalb ein **pragmatischer,
  literaturbasierter Ansatz** vorgeschlagen (Namenskonventionen, die in der Schweizer CAD-Praxis laut
  Sekundärquellen und allgemein verbreiteten Layer-Präfix-Mustern kursieren — teils aus SIA 400/eBKP-H-
  Nomenklatur, teils aus Bürostandards), **mit expliziter Markierung als unsicher/erweiterbar**.

Vorschlag Regex→Klasse-Lookup-Tabelle (bewusst tolerant/erweiterbar, GROSS/klein und Trennzeichen `_`/`-`/` `
ignorierend, Praxis-Namen aus mehreren Büro-/Kantons-Konventionen kombiniert — **unsicher, muss mit
realen Kunden-DXF-Layerlisten abgeglichen werden**):

```python
import re

LAYER_RULES: list[tuple[re.Pattern, str]] = [
    (re.compile(r"WAND|MAUER|A[-_ ]?WAND", re.I), "wall"),
    (re.compile(r"TRAG|TRAGWERK|MASSIV", re.I), "wall_loadbearing"),
    (re.compile(r"ST(UE|Ü)TZE|STUETZEN|COLUMN", re.I), "column"),
    (re.compile(r"DECKE|SLAB|BODEN(PLATTE)?", re.I), "slab"),
    (re.compile(r"FENSTER|WINDOW", re.I), "window"),
    (re.compile(r"T(UE|Ü)R|DOOR|TOR", re.I), "door"),
    (re.compile(r"AUSSPARUNG|OEFFNUNG|OPENING", re.I), "opening_generic"),
    (re.compile(r"LIFT|AUFZUG|SCHACHT", re.I), "shaft"),
    (re.compile(r"BEMASSUNG|KOTE|DIM(ENSION)?", re.I), "annotation_dimension"),
    (re.compile(r"^TEXT|BESCHRIFTUNG|LABEL", re.I), "annotation_text"),
    (re.compile(r"SCHRAFFUR|HATCH|MATERIAL", re.I), "hatch_material"),
    (re.compile(r"ACHSE|RASTER|GRID", re.I), "axis_grid"),
]

def classify_layer(name: str) -> str | None:
    for pattern, klass in LAYER_RULES:
        if pattern.search(name):
            return klass
    return None  # unbekannt -> manuelle Zuordnung / Fallback auf Geometrie-Heuristik
```

**Ausdrücklich unsicher / offene Fragen an den Auftraggeber** (siehe Abschnitt am Ende): exakte
Layernamen der tatsächlich einliefernden Büros, ob SIA-2014-Konformität überhaupt eingehalten wird
(in der Praxis weichen viele Büros vom Standard ab), ob eBKP-H-Codes in Layernamen vorkommen (z. B.
`C2.1`, `C4`) — dafür bräuchte man reale Kunden-Pläne oder den (kostenpflichtigen) SIA-2014-Volltext.

---

## H. Stand der Technik Plan→BIM

- **CubiCasa5K**: öffentlicher Raster-Grundriss-Datensatz (4199/399/399 Train/Val/Test), 11 annotierte
  Klassen; De-facto-Benchmark für Deep-Learning-Grundrisserkennung
  (https://art-programmer.github.io/floorplan-transformation.html,
  https://arxiv.org/pdf/1908.11025 "Deep Floor Plan Recognition").
- **"Raster-to-Vector: Revisiting Floorplan Transformation"** (Liu et al., ICCV 2017,
  https://www.researchgate.net/publication/322059565): zweistufiger Ansatz — CNN erkennt Eckpunkte
  (Junctions) mit geometrischer/semantischer Bedeutung, danach Integer-Programming/Kombinatorik zur
  Aggregation zu Primitiven (Wandlinien, Türlinien, Icon-Boxen). Klassiker des Feldes.
  Neuere Arbeiten (2024/2026, per Websuche gefunden, nicht im Detail gelesen): "Raster-to-Graph" (Hu et al.,
  Computer Graphics Forum 2024), "ArchCAD-400K" (CAD-Symbol-Spotting-Datensatz), "Raster2Seq" (2026).
- **WiseBIM / Plans2BIM** (kommerziell, https://wisebim.fr/software/plans2bim/,
  https://www.buildingsmart.org/wp-content/uploads/2022/10/428-TECHNOLOGY-Plans2BIM.pdf): Cloud-SaaS,
  nimmt sowohl Raster (PDF/PNG/JPEG) als auch Vektor (DWG/DXF) entgegen, erkennt Wände/Fenster/Türen/
  Decken per KI, Output als Revit-BIM/IFC/DXF/Mengen (CSV/XLSX). Bestätigt die grundsätzliche
  Machbarkeit einer gemischten Vektor+Raster-Pipeline, wie sie hier verlangt ist.
- **Sketch2BIM**: in der Websuche nicht separat mit belastbaren Primärquellen gefunden (nur Erwähnung als
  Suchbegriff) — **offen**, keine belastbare Aussage möglich ohne weitere Recherche.

**Ehrliche Einschätzung, was übernehmbar ist**:
- **Vektor-DXF-Eingaben (Wandachsen aus zwei Parallelen, Stützen als Kreis/Rechteck-Entity, Öffnungen aus
  Block-Inserts)**: Die in Frage F beschriebene **Parallel-Linien-Heuristik + shapely-Polygonisierung**
  ist für sauber gezeichnete CAD-Vektordaten ausreichend und **nicht** auf ML angewiesen — das deckt sich
  mit der Beobachtung, dass kommerzielle Tools wie Plans2BIM DWG/DXF-Eingaben separat (einfacher) als
  Rasterbilder behandeln.
- **Raster ohne Layerinformation (Scan/Bild)**: Hier ist die klassische CV-Pipeline (Hough/Konturen,
  Frage E) für rohe Linienerkennung nutzbar, aber die **Semantik-Trennung Wand vs. Bemassung vs. Symbol**
  ist bei Rasterbildern ohne Zusatzwissen ein hartes, forschungsrelevantes Problem (deshalb die
  ML-Datensätze/-Modelle wie CubiCasa5K/Raster-to-Vector). Ein Nachbau eines trainierten CNN-Modells ist
  **ausserhalb des Scopes** dieses Werkzeugs (keine ML-Bibliothek/kein Trainingsdatensatz vorgesehen) —
  für Rasterpläne ist daher realistisch: (a) möglichst nur unterstützend (Kontur-/Linienvorschläge), (b)
  Vision-LLM für Klassifikation/Label wie in Frage E beschrieben, (c) im Zweifel manuelle Nacharbeit
  einplanen, nicht vollautomatische Extraktion versprechen.

---

## I. Schnittpläne: Geschosslinien, Deckenstärken, Höhenkoten

**Ansatz** (fachlich abgeleitet, keine fixe Library-Funktion dafür): Geschossdecken erscheinen im
DXF-Schnitt typischerweise als **zwei parallele horizontale Linien/Polylinien** im Abstand der
Deckenstärke, oft auf einem eigenen Layer (`DECKE`, siehe Frage G). Höhenkoten sind meist:
- **TEXT/MTEXT-Entities** mit charakteristischem Zahlenformat (`+412.35`, `±0.00`, `-3.15`) — per Regex
  auf `e.dxf.text` (bzw. `MText.plain_text()`) matchbar (`re.match(r"^[+\-±]?\d+\.\d{2}$")`).
- **Höhenkoten-Blöcke** (INSERT eines Symbol-Blocks, z. B. Dreieck mit Textattribut) — dafür muss der
  Block per `virtual_entities()`/`explode()` aufgelöst und nach enthaltenem TEXT/ATTRIB gesucht werden;
  ezdxf unterstützt Block-Attribute über `Insert.attribs` (Attribut-Entities im Block) — **diese
  ATTRIB-API wurde in dieser Session nicht am lebenden Objekt getestet**, nur die verwandte `virtual_
  entities`/`explode`-API (siehe Evidence-Tabelle); für produktiven Code muss `Insert.attribs`/
  `Attrib`-Klasse noch gezielt gegen die offizielle Doku verifiziert werden (**offene Aufgabe**).
- **Bemassungen (`DIMENSION`)**: liefern über `get_measurement() -> float` den gemessenen Wert und über
  `dxf.text` den Anzeige-Override (Default `'<>'` = automatisch, siehe Probe-Ergebnis in Frage C). Für
  Geschosshöhen wird meist eine lineare vertikale Bemassung zwischen zwei Referenzlinien verwendet;
  `get_measurement()` liefert dann direkt die Geschosshöhe in Zeichnungseinheiten (Skalierung via
  `$INSUNITS`, siehe Frage B/J).

**Praktische Erkennung von Geschosslinien**: horizontale Linien-Cluster (nahezu 0° oder 180°) mit
gleichem Y über die volle Schnittbreite, kombiniert mit angrenzendem Höhenkoten-Text, sind ein robuster
Kandidat für "Geschossdecke Oberkante/Unterkante".

---

## J. Stolpersteine

- **Einheiten (mm vs. m)**: `$INSUNITS` (Header-Variable, Frage B) muss ausgewertet werden; Schweizer
  Architekturbüros zeichnen häufig in **mm**, manche in **m** — ohne Prüfung von `$INSUNITS` kann eine
  Wanddicke um Faktor 1000 falsch interpretiert werden. `ezdxf.units.decode(code) -> str` liefert die
  Klartext-Einheit (verifiziert: `decode(6) == 'm'`).
- **Blocks mit Skalierung**: `INSERT`-Entities haben `dxf.xscale/yscale/zscale/rotation` — beim Lesen
  über `virtual_entities()` werden diese laut ezdxf-API bereits transformiert zurückgegeben (das ist der
  dokumentierte Zweck der Methode), muss aber im produktiven Code durch einen gezielten Test mit
  skaliertem Block abgesichert werden (in dieser Session nicht mit ungleichförmiger Skalierung getestet
  — **offene Verifikationsaufgabe**).
- **Polylinien mit Bulge (Bögen)**: `LWPolyline.get_points(format='xyseb')` liefert je Punkt
  `(x, y, start_width, end_width, bulge)` — ein Bulge ≠ 0 bedeutet, das Segment zum nächsten Punkt ist ein
  Kreisbogen, keine Gerade (verifiziert per Signatur/Doku-String der Methode). Wird das ignoriert,
  werden Rundungen/Bögen als Geraden fehlinterpretiert (z. B. gerundete Wandecken, Bogenfenster).
- **Splines**: DXF `SPLINE`-Entities (in dieser Session nicht selbst erzeugt/gelesen) approximieren
  Freiformkurven; für Wanderkennung i. d. R. selten (Wände sind gerade/bogenförmig), aber bei
  Bogenwänden/Terrassen können Splines auftreten und benötigen eine Flatten-Routine
  (`ezdxf.entities.Spline.flattening(distance)` — **API nicht in dieser Session verifiziert, nur aus
  Namenskonvention der Bibliothek vermutet — offene Prüfung**).
- **XREFs (externe Referenzen)**: Ein `INSERT` kann auf einen extern referenzierten Block (XREF-Datei)
  verweisen, dessen Inhalt nicht in der eigenen DXF-Datei liegt, sondern in einer verlinkten externen
  Datei — wird die XREF-Datei nicht mitgeliefert, bleibt der Block-Inhalt leer. Für Extraktion muss die
  Ordnerstruktur/den Suchpfad der XREFs mitgegeben werden (**offene Frage an den Auftraggeber**: liefern
  Büros vollständig "gebundene" DXF/DWG oder mit externen XREFs?).
- **Proxy-Entities**: DXF-Objekte aus proprietären AutoCAD-Erweiterungen/Fremd-Plugins, die ezdxf nicht
  interpretieren kann, werden als generische "Proxy"-Objekte behandelt bzw. beim Parsen übersprungen/
  vereinfacht — kann zu stillem Geometrieverlust führen; sollte über Logging der unbekannten
  DXF-Typen abgesichert werden.
- **DWG-Version**: verschiedene AutoCAD-Versionen (R12…R2018+) haben unterschiedliche Binärformate —
  odafc deckt laut Doku R12…R2018 ab; neuere DWG-Versionen (falls Architekturbüro sehr aktuelles AutoCAD
  nutzt) müssen gegen die odafc-Versionsliste geprüft werden.
- **PDF ohne Vektoren (nur Bilder)**: gescannte Pläne oder "Rasterdruck ins PDF" liefern bei
  `page.get_drawings()` eine leere/fast leere Liste und bei `get_text()` keinen Text — Fallback ist dann
  zwingend `page.get_pixmap()` → OpenCV-Pipeline (Frage E). Muss vor der eigentlichen Extraktion per
  Heuristik erkannt werden (z. B. Anzahl `get_drawings()`-Items nahe 0 bei gleichzeitig grossem
  eingebettetem Bild).
- **Text-Encoding**: `ezdxf.readfile(..., encoding=None)` — DXF-Dateien älterer AutoCAD-Versionen
  können in einer nicht-UTF8-Kodierung vorliegen (Windows-1252 o. ä.); `encoding=None` lässt ezdxf laut
  Signatur selbst entscheiden (autodetect über `$DWGCODEPAGE`), sollte aber bei Umlauten (Ä/Ö/Ü in
  Schweizer Bauteilbezeichnungen) im Praxistest verifiziert werden.
- **Koordinatenursprung/UCS**: DXF-Koordinaten sind relativ zum WCS (World Coordinate System); ein
  Plan kann eine vom Ursprung abweichende UCS/Einfügepunkt-Konvention verwenden (z. B. Koordinaten im
  Landesvermessungssystem statt lokal 0/0) — vor jeder Massstabs-/Distanzberechnung sollte die
  Bounding Box (`ezdxf.bbox.extents`) geprüft werden, um Plausibilität (z. B. "liegen alle Koordinaten
  im Millionenbereich → Schweizer LV95-Koordinaten?") zu erkennen.
- **Massstab im Layout/Papierraum**: falls doch im Papierraum/Layout mit Viewport gearbeitet wird, gilt
  ein zusätzlicher Skalierungsfaktor zwischen Modelspace- und Layout-Einheiten (Viewport-`dxf.
  view_center_point`/`dxf.zoom` bzw. der `PLINSUNITS`), der bei reiner Modelspace-Extraktion nicht
  benötigt wird, aber bei Layout-gebundener Geometrie zu falschen Massen führt, wenn ignoriert.

---

## Offene Fragen an den Auftraggeber

1. **ODA File Converter**: Ist er auf dem Windows-Arbeitsplatz des Auftraggebers bereits installiert,
   oder muss die Installation Teil des Lieferumfangs/der Abnahme sein? (Ohne ihn: kein DWG-Import.)
2. **CAD-Software der Architekturbüros**: Welche Software wird bei den einliefernden Büros tatsächlich
   eingesetzt (AutoCAD, ArchiCAD, Vectorworks, Allplan selbst)? Das beeinflusst Layernamen, Bemassungsstil,
   Block-/Attribut-Konventionen und PDF-Exportverhalten (echter Text vs. Kurven).
3. **Liegen DWG oder nur PDF vor?** Falls durchgängig nur PDF vorliegt, entfällt Frage A/odafc, aber die
   Vektor-vs-Raster-Weiche (Frage D/E) wird zur Kernfrage — insbesondere ob die PDFs echten Text/
   Vektorpfade enthalten oder reine Scans sind.
4. **Massstab**: Ist der Planmassstab (z. B. 1:50, 1:100) maschinenlesbar hinterlegt (Titelblock-Text in
   festem Format) oder muss er heuristisch/interaktiv bestimmt werden?
5. **SIA-2014-Konformität der Layer**: Halten sich die einliefernden Büros überhaupt an SIA 2014/eBKP-H,
   oder gibt es Büro-eigene Layernamen? Idealerweise 2–3 reale (anonymisierte) Beispiel-DXF/DWG zur
   Kalibrierung der Layer-Lookup-Tabelle aus Frage G.
6. **XREFs**: Werden DXF/DWG-Dateien mit gebundenen (bind) Blöcken geliefert oder mit externen
   Referenzen, die separat mitgeliefert werden müssten?
7. **SIA-2014-Volltext**: Soll der SIA-2014-Layerschlüssel offiziell (kostenpflichtig,
   https://shop.sia.ch/normenwerk/architekt/2014_2017_d/D/Product) beschafft werden, um die
   Lookup-Tabelle aus Frage G zu verifizieren, statt sich auf öffentlich zugängliche Sekundärquellen
   (kantonale CAD-Richtlinien) zu stützen?
8. **Höhenkoten-Blöcke/Attribute**: Gibt es einen Standard-Kotenblock, den alle Büros nutzen (Name,
   Attributstruktur), oder ist mit sehr heterogenen Darstellungen zu rechnen? Beeinflusst, ob
   `Insert.attribs`/Attribut-Parsing (siehe Frage I, offene Verifikationsaufgabe) zentral wichtig wird.

---

## Anhang: Probe-Skript-Ausgabe (wörtlich)

Ausgeführt in `/tmp/claude-0/-home-user-plan2allplan/cec3c10c-725f-583f-94fd-2cc650e8bb6c/scratchpad/extract_probe.py`
(nicht Teil des Repos). Zusätzliche Laufzeitabhängigkeiten `matplotlib` und `pillow` wurden für den
Test nachinstalliert (in der vorgegebenen Bibliotheksliste nicht enthalten, aber von
`ezdxf.addons.drawing` intern importiert — siehe Frage C, Stolperstein).

```
=== 1) DXF geschrieben: .../scratchpad/probe.dxf
=== 2) $INSUNITS beim Wiedereinlesen: 6
Layer im Dokument: ['0', 'Defpoints', 'A_WAND', 'A_BEMASSUNG']
Entity: LWPOLYLINE Layer: A_WAND Punkte: [(0.0, 0.0), (5.0, 0.0)]
Entity: LWPOLYLINE Layer: A_WAND Punkte: [(0.0, 0.2), (5.0, 0.2)]
Entity: TEXT Layer: A_BEMASSUNG Text: +412.35 Insert: (2.5, 0.5, 0.0)
=== 3) Gerendert: .../scratchpad/probe.pdf .../scratchpad/probe.png
=== 4) Anzahl get_drawings() Items: 4
  drawing[1] type: s items: [('l', Point(52.36, 143.55), Point(1099.64, 143.55))]
  drawing[1] color: (1.0, 0.0, 0.0) width: 0.25 fill: None
  drawing[2] type: s items: [('l', Point(52.36, 101.66), Point(1099.64, 101.66))]
  drawing[2] color: (1.0, 0.0, 0.0) width: 0.25 fill: None
  drawing[0]/[3]: type f (fill) mit langen 'l'/'c'-Pfadlisten -> gerenderter TEXT/Hintergrund als Fläche
=== get_text('dict') blocks: 0
=== FERTIG ===
```

Die beiden Wandlinien (`A_WAND`) erscheinen korrekt als eigenständige Stroke-Drawings (`type 's'`,
`items=[('l', p1, p2)]`), skaliert/transformiert in PDF-Punkt-Koordinaten durch den matplotlib-Export
(Ausgangs-Y-Werte 0.0/0.2 m wurden zu PDF-Y 143.55/101.66 pt — Achsenrichtung invertiert, Massstab durch
`qsave`-DPI/Figure-Grösse bestimmt, nicht 1:1 mit den DXF-Modelleinheiten). Der TEXT "+412.35" ist im
PDF nur als gefüllte Kurvenfläche vorhanden (`type 'f'` mit sehr vielen `'l'`/`'c'`-Segmenten für die
Ziffern-Glyphen) — entsprechend liefert `get_text("dict")` **0 Blöcke**, die exakte Bestätigung des
Stolpersteins aus Frage C/D.
