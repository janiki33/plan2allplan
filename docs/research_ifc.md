# Recherche: IFC4-Erzeugung mit ifcopenshell für nativen Allplan-2026-Import

Agent: `research-ifc`. Umgebung: ifcopenshell **0.8.5** (installiert, Linux-Session).
Quellen: installierter Quellcode/Docstrings (Modulpfad `IOS/` =
`/usr/local/lib/python3.11/dist-packages/ifcopenshell/`), https://docs.ifcopenshell.org,
https://help.allplan.com. Alle zitierten Symbole stehen mit Fundstelle in
`docs/evidence_ifc.md`. Verifikationsskript: `ifc_probe.py` (Scratchpad, nicht im Repo),
Ausgabe siehe Abschnitt **Verifikation** am Ende.

**Wichtiger Versionshinweis:** In ifcopenshell 0.8.5 heisst das Öffnungs-API
`ifcopenshell.api.feature.add_feature` (nicht `void.add_opening` — das Modul `api/void`
existiert in dieser Version nicht mehr, geprüft per `ls api/`). Falls der Auftraggeber
mit einer anderen ifcopenshell-Version arbeitet, muss das erneut geprüft werden.

---

## A. Projektgerüst mit ifcopenshell.api

```python
import ifcopenshell.api.project, ifcopenshell.api.root, ifcopenshell.api.unit
import ifcopenshell.api.context, ifcopenshell.api.aggregate, ifcopenshell.api.spatial

model = ifcopenshell.api.project.create_file(version="IFC4")
project = ifcopenshell.api.root.create_entity(model, ifc_class="IfcProject", name="...")

length = ifcopenshell.api.unit.add_si_unit(model, unit_type="LENGTHUNIT", prefix="MILLI")
area = ifcopenshell.api.unit.add_si_unit(model, unit_type="AREAUNIT")
volume = ifcopenshell.api.unit.add_si_unit(model, unit_type="VOLUMEUNIT")
ifcopenshell.api.unit.assign_unit(model, units=[length, area, volume])

model3d = ifcopenshell.api.context.add_context(model, context_type="Model")
body = ifcopenshell.api.context.add_context(model, context_type="Model",
    context_identifier="Body", target_view="MODEL_VIEW", parent=model3d)

site = ifcopenshell.api.root.create_entity(model, ifc_class="IfcSite", name="...")
building = ifcopenshell.api.root.create_entity(model, ifc_class="IfcBuilding", name="...")
storey = ifcopenshell.api.root.create_entity(model, ifc_class="IfcBuildingStorey", name="EG")

ifcopenshell.api.aggregate.assign_object(model, relating_object=project, products=[site])
ifcopenshell.api.aggregate.assign_object(model, relating_object=site, products=[building])
ifcopenshell.api.aggregate.assign_object(model, relating_object=building, products=[storey])
```

Signaturen (siehe evidence_ifc.md für Zeilen):
- `project.create_file(version="IFC4") -> ifcopenshell.file`
- `root.create_entity(file, ifc_class, predefined_type=None, name=None) -> entity_instance`
- `unit.add_si_unit(file, unit_type="LENGTHUNIT", prefix=None) -> entity_instance`
- `unit.assign_unit(file, units=None, length=None, area=None, volume=None) -> entity_instance`
- `context.add_context(file, context_type=None, context_identifier=None, target_view=None, target_scale=None, parent=None) -> entity_instance`
- `aggregate.assign_object(file, products, relating_object) -> entity_instance | None`
- `spatial.assign_container(file, products, relating_structure) -> entity_instance | None`

**Meter oder Millimeter?** `unit.assign_unit()` ohne Argumente erzeugt per Konvention
Millimeter (Länge), m² (Fläche), m³ (Volumen) — Kommentar im Quellcode nennt das explizit
eine "convenience function" für genau diesen Zweck. Die Allplan-Hilfe zum IFC-Import
(https://help.allplan.com/Allplan/2023-0/1033/Allplan/320465.htm) bestätigt: "Allplan
automatically imports the data using the source file's unit of length" — Allplan liest
also die im IFC-Header definierte Einheit selbst aus und rechnet intern in Meter um.
**Es gibt keine Allplan-2026-spezifische Quelle, die explizit sagt, Millimeter würden
"sauberer" importiert als Meter.** Empfehlung (Annahme, keine harte Quelle): Millimeter
verwenden, weil (a) das der ifcopenshell-Standardkomfort ist, (b) es in der Architektur-
/Rohbau-Praxis (mm-genaue Wanddicken, Aussparungen) verbreitet ist und Rundungsfehler bei
sehr kleinen Layer-Dicken vermeidet. **Offene Frage an Auftraggeber**, siehe unten.

## B. IfcBuildingStorey: Elevation, Hierarchie

- `Name` und `Elevation` sind normale Attribute (`storey.Elevation = 0.0` in Metern-Rohwert
  gemäss Projekteinheit, siehe IfcOpenShell-Doku "Elevation attribute represents the
  elevation of the base of a storey relative to the 0.00 internal reference height of the
  building" — docs.ifcopenshell.org, Class IfcBuildingStorey).
- Hierarchie zwingend: `IfcProject` –(Aggregation)→ `IfcSite` –(Aggregation)→ `IfcBuilding`
  –(Aggregation)→ `IfcBuildingStorey`. Jedes physische Element wird per **Containment**
  (`spatial.assign_container`) einem `IfcBuildingStorey` zugeordnet, nicht per Aggregation
  (Doku-Unterscheidung in `aggregate.assign_object`: Aggregation = "large space made of
  smaller spaces", Containment = "physical product in a virtual space").
- Laut Allplan-Import-Hilfeseite ist "Geschosszuordnung" (Storey designation) **nur beim
  Export** ein Schalter, standardmässig deaktiviert — für den **Import** wird nicht
  explizit dokumentiert, ob/wie Allplan IfcBuildingStorey automatisch in die
  Bauwerksstruktur (Geschosse) übernimmt. Das ist eine **offene Frage** (siehe unten).

## C. IfcWall: Repräsentation, Achse, Placement, Material

- `IfcWallStandardCase` existiert in IFC4 weiterhin als Schema-Entität (Laufzeitprüfung:
  `ifcopenshell_wrapper.schema_by_name("IFC4").declaration_by_name("IfcWallStandardCase")`
  liefert eine gültige Entity-Deklaration). Die Allplan-Importhilfe verwendet exakt diese
  Unterscheidung: **"IfcWallStandardCase (gerade Wände) oder IfcWall (kreisförmig,
  freiform, Elementwand)"** — d.h. gerade Wände sollten als `IfcWallStandardCase`
  exportiert werden, um von Allplan sicher als Wand erkannt zu werden.
- Geometrie: `geometry.add_wall_representation(file, context, length, height,
  direction_sense="POSITIVE", offset=0.0, thickness=0.2, x_angle=0.0, clippings=None,
  booleans=None)` erzeugt eine `IfcShapeRepresentation` mit `IfcExtrudedAreaSolid` über
  einem Rechteckprofil (Body/Model/MODEL_VIEW-Kontext). Danach
  `geometry.assign_representation(file, product=wall, representation=rep)`.
- Achse: `geometry.add_axis_representation(file, context, axis=[(x0,y0),(x1,y1)])` mit
  Kontext `Model/Axis/GRAPH_VIEW` (3D) oder `Plan/Axis/GRAPH_VIEW` (2D) — Reihenfolge
  wichtig: Start = minimales lokales X, Ende = maximales lokales X. Laut Docstring "highly
  recommended for standard representations of walls" für Konnektivität und parametrisches
  Strecken. Ebenfalls per `assign_representation` an das Wand-Objekt hängen (zusätzlich
  zur Body-Repräsentation).
- Placement: `geometry.edit_object_placement(file, product, matrix=None, is_si=True,
  should_transform_children=False)` — 4×4-Matrix (numpy), Default Identität. Nur lokale
  Placements werden unterstützt (kein Grid-/Linear-Placement).
- Material: `IfcMaterialLayerSet` gehört an den **Typ** (`IfcWallType`), nicht an die
  Instanz. Ablauf: `material.add_material_set(set_type="IfcMaterialLayerSet")` →
  `material.add_material(name, category)` → `material.add_layer(layer_set, material)` →
  `material.edit_layer(layer, attributes={"LayerThickness": ...})` →
  `material.assign_material(products=[wall_type], type="IfcMaterialLayerSet",
  material=material_set)` → `type.assign_type(related_objects=[wall],
  relating_type=wall_type)` → **zusätzlich** an der Instanz:
  `material.assign_material(products=[wall], type="IfcMaterialLayerSetUsage")` (Material
  wird automatisch vom Typ abgeleitet). Der letzte Schritt ist **notwendig** für
  IFC4-Validität (siehe Stolperstein I unten, per `ifcopenshell.validate` bestätigt).

## D. IfcSlab: PredefinedType, Kontur mit Löchern, Extrusion

- `PredefinedType` aus `IfcSlabTypeEnum`: FLOOR, ROOF, LANDING, BASESLAB, USERDEFINED,
  NOTDEFINED (Laufzeitprüfung der Schema-Enum). Für Bodenplatte → `BASESLAB`, für
  Zwischendecke → `FLOOR`.
- Zwei API-Wege für die Geometrie:
  1. `geometry.add_slab_representation(file, context, depth=0.2, polyline=[...])` — nimmt
     ein einfaches Polygon **ohne** Löcher (`polyline`-Parameter ist eine flache
     Punktliste, keine Voids-Unterstützung laut Quellcode).
  2. Für Konturen **mit Löchern** (Aussparungen, Liftgrube-Kontur im Grundriss):
     `profile.add_arbitrary_profile_with_voids(file, outer_profile=[...],
     inner_profiles=[[...], ...], name=...)` → `IfcArbitraryProfileDefWithVoids`, danach
     `geometry.add_profile_representation(file, context, profile, depth=0.3)` →
     `assign_representation`. **Achtung Bug**, siehe Stolperstein I.
- Extrusion nach unten/oben: Vorzeichen/Richtung wird über die Objekt-Placement-Matrix
  gesteuert (Slab-Unterkante am Ursprung, `depth` immer positiv in Extrusionsrichtung
  +Z lokal) — für "Extrusion nach unten" die Placement-Matrix so setzen, dass lokal +Z
  nach unten zeigt, oder die Platte an der Oberkante platzieren und mit negativem Z-Offset
  in der Matrix nach unten verschieben (im Probe-Skript so gemacht: `matrix[2,3] = -depth`
  bei einer Platte, deren Oberkante am Geschossbezug liegt).
- Position: wie bei Wand über `geometry.edit_object_placement` + `spatial.assign_container`
  zum Geschoss.

## E. IfcColumn: rechteckig / rund

- `PredefinedType` aus `IfcColumnTypeEnum`: COLUMN, PILASTER, USERDEFINED, NOTDEFINED.
- Es gibt eine dedizierte, aber sehr dünne API-Funktion:
  `ifcopenshell.api.profile.add_parameterized_profile(file, ifc_class: str,
  profile_type: str="AREA") -> ifcopenshell.entity_instance`. Docstring-Beispiel:
  ```python
  circle = ifcopenshell.api.profile.add_parameterized_profile(model, ifc_class="IfcCircleProfileDef")
  circle.Radius = 1.
  ```
  Die Funktion ruft laut eigenem Docstring intern nur `file.create_entity(ifc_class,
  ProfileType=profile_type)` auf ("Currently, this API has no benefit over directly
  calling ifcopenshell.file.create_entity") — d.h. Attribute wie `XDim`/`YDim` (Rechteck)
  bzw. `Radius` (Kreis) müssen danach direkt gesetzt werden.
- Rechteckig: `profile = ifcopenshell.api.profile.add_parameterized_profile(model,
  ifc_class="IfcRectangleProfileDef"); profile.XDim = 0.4; profile.YDim = 0.4` (optional
  `profile.Position` für Versatz setzen).
- Rund: `profile = ifcopenshell.api.profile.add_parameterized_profile(model,
  ifc_class="IfcCircleProfileDef"); profile.Radius = 0.2`.
- Danach: `geometry.add_profile_representation(file, context, profile, depth=Höhe,
  cardinal_point=5)` (cardinal_point 5 = "mid-depth centre", d.h. Profil zentriert um die
  Achse — praktisch für Stützen) → `assign_representation`. Zusätzlich Achsen-Repräsentation
  analog Wand für Konnektivität (Start = min. lokales Z, Ende = max. lokales Z, laut
  `add_axis_representation`-Docstring für Balken/Stützen).

## F. IfcOpeningElement für Aussparungen / nicht durchgehende Nischen

- API (0.8.5): `ifcopenshell.api.feature.add_feature(file, feature=opening_element,
  element=wall_or_slab) -> IfcRelVoidsElement`. **Nicht** `void.add_opening` — dieses
  Modul existiert in 0.8.5 nicht mehr (siehe Versionshinweis oben).
- Ablauf laut Docstring-Beispiel: `IfcOpeningElement` per `root.create_entity` anlegen,
  eigene Geometrie per `geometry.add_wall_representation` (oder Profile) + `assign_
  representation`, eigenes Placement per `edit_object_placement`, dann `feature.
  add_feature(model, feature=opening, element=wall)`. Die Docstring-Empfehlung: die
  Opening-Repräsentation etwas **dicker** als das Wirtselement zu machen ("thickness
  greater than the wall thickness ... helps resolve floating point resolution errors"),
  damit die Boolesche Operation sauber durchschneidet.
- **Nicht durchgehende Nische** (Tiefe < Wanddicke): funktioniert identisch — die Tiefe
  der Opening-Geometrie (z.B. `thickness=0.1` bei einer 0.2 m dicken Wand) bestimmt die
  Nischentiefe; es gibt keinen speziellen "Nischen"-Typ in IFC4, es ist einfach ein
  `IfcOpeningElement`, dessen Extrusionskörper die Wand nicht vollständig durchdringt.
  Im Verifikationslauf erfolgreich getestet (Wand 0.2 m dick, Opening 0.1 m dick,
  `by_type("IfcOpeningElement")` liefert das Element zurück, Validate ohne Fehler).
- Für Decken analog: `feature.add_feature(model, feature=opening, element=slab)`.

## G. Property-Sets

- `pset.add_pset(file, product, name: str, ifc2x3_subclass=None) -> IfcPropertySet` legt
  ein leeres, benanntes Pset an.
- `pset.edit_pset(file, pset, name=None, properties: dict=None, pset_template=None,
  should_purge=True) -> None` setzt/ändert/löscht (Wert `None`) einzelne Properties. Wird
  ein Standard-Pset-Name verwendet (`Pset_WallCommon` etc.), zieht ifcopenshell
  automatisch die eingebauten buildingSMART-Templates heran, um den korrekten IFC-
  Datentyp zu wählen (laut Docstring: "The built-in buildingSMART templates are always
  loaded"). Beispiel: `pset.edit_pset(model, pset=p, properties={"LoadBearing": True,
  "IsExternal": False})` auf einem zuvor mit `add_pset(name="Pset_WallCommon")` erzeugten
  Pset.
- Für eigene/projektspezifische Attribute wie «Brüstung», «Sturz», «Confidence»: eigenes
  Pset mit eigenem Präfix (nicht `Pset_`) anlegen, z.B. `Plan2Allplan_WallCommon`, und
  Properties frei benennen — Datentyp wird dann aus dem Python-Wert abgeleitet (bool→
  IfcBoolean, str→IfcText/IfcLabel, float→IfcReal, je nach Docstring-Verhalten von
  `edit_pset`).

## H. Round-Trip (IFC → JSON) für automatische Tests

```python
model2 = ifcopenshell.open(path)          # ifcopenshell.open(path) -> ifcopenshell.file
walls = model2.by_type("IfcWallStandardCase")   # by_type(name) -> list[entity_instance]
settings = ifcopenshell.geom.settings()
shape = ifcopenshell.geom.create_shape(settings, walls[0])   # -> ShapeElementType, .geometry
verts = ifcopenshell.util.shape.get_vertices(shape.geometry) # -> np.ndarray[N,3]
```
- `ifcopenshell.geom.create_shape(settings, inst, repr=None,
  geometry_library="opencascade")`: bei `inst` = `IfcProduct` liefert es ein Objekt mit
  `.geometry` (verwendbar mit `ifcopenshell.util.shape`), Standard-Backend "opencascade".
  Für einfache Bounding-Box-/Vertex-Prüfungen im Test-Loop ausreichend, ohne dass eine
  echte 3D-Bibliothek im Testcode selbst eingebunden werden muss.
- Für "IFC → JSON"-Vergleich mit Ground-Truth-Daten: pro erzeugtem Element `GlobalId`,
  `is_a()`, `Name`, `PredefinedType`, Bounding-Box/Volumen aus `create_shape`, sowie die
  Pset-Werte (`ifcopenshell.util.element.get_psets(element)` — **nicht selbst
  verifiziert**, nur aus Modulname abgeleitet; falls verwendet, vorher Docstring lesen und
  in evidence_ifc.md nachtragen) extrahieren und mit der Ground-Truth-JSON abgleichen.

## I. Bekannte Stolpersteine

1. **Proxy statt Wand**: Laut Allplan-Importhilfe (help.allplan.com, "IFC Import
   Settings" (advanced), 2023-0) werden nicht eindeutig zuordenbare Objekte als
   `IfcBuildingElementProxy` importiert. Für Wände sicher `IfcWallStandardCase`
   (gerade) bzw. `IfcWall` (gekrümmt/frei) verwenden, für Stützen `IfcColumn`, für
   Decken `IfcSlab`, für Öffnungen `IfcOpeningElement`/gefüllte Öffnungen als
   `IfcOpening`-Kategorie (Fenster/Tür/Nische/Aussparung laut Hilfeseite). **Offen**: ob
   zusätzlich eine Axis-Representation zwingend nötig ist, um NICHT als Proxy zu landen
   — dazu keine explizite Allplan-Quelle gefunden (siehe offene Fragen).
2. **`IfcMaterialLayerSet` direkt an der Wand-Instanz statt `IfcMaterialLayerSetUsage`**:
   Im Verifikationslauf hat `ifcopenshell.validate.validate(..., express_rules=True)`
   dies tatsächlich als Fehler gemeldet: `IfcWallStandardCase.HasMaterialLayerSetUsage`
   verlangt eine `IfcMaterialLayerSetUsage`-Relation an der Instanz, nicht direkt das
   `IfcMaterialLayerSet` (das gehört an den `IfcWallType`). Siehe Abschnitt C für den
   korrekten Ablauf. Wortlaut der Validate-Fehlermeldung im Verifikationsteil unten.
3. **`profile.add_arbitrary_profile_with_voids` erzeugt ungültige äussere Kontur**: in
   ifcopenshell 0.8.5 baut die Funktion die äussere Kurve **immer** als
   `IfcCartesianPointList3D`, selbst wenn 2D-Koordinaten übergeben werden. Das verletzt
   `IfcArbitraryClosedProfileDef.WR1` (die äussere Kurve eines Profils muss `Dim==2`
   sein), was `ifcopenshell.validate` konkret anmeckert (siehe Verifikationsteil unten,
   erster Lauf). **Workaround** (im Probe-Skript verwendet): die äussere Kurve manuell
   über `file.create_entity("IfcCartesianPointList2D", ...)` +
   `file.create_entity("IfcIndexedPolyCurve", ...)` bauen und direkt
   `IfcArbitraryProfileDefWithVoids` erzeugen, statt die Komfortfunktion zu nutzen. Für
   Bodenplatten-Konturen mit Aussparungen/Liftgrube also **nicht** die High-Level-API für
   den Aussenring verwenden.
4. **Einheiten**: siehe Abschnitt A — Allplan liest die IFC-Header-Einheit selbst aus,
   rechnet aber intern immer in Metern. Kein bekannter Fallstrick bei mm vs. m per se,
   aber unbedingt konsistent (alle Contexts/Elemente in derselben Modell-Einheit,
   Property-Werte mit korrektem IFC-Messtyp, z.B. `IfcLengthMeasure` in Projekteinheit
   nicht in SI-Metern hartkodiert — `edit_layer`/`add_wall_representation` etc.
   rechnen bereits selbst über `ifcopenshell.util.unit.calculate_unit_scale` um, wenn man
   die API-Funktionen mit SI-Meter-Werten füttert; bei manuellem `file.create_entity`
   (z.B. für den Voids-Workaround) muss man **selbst** durch `unit_scale` teilen, siehe
   Probe-Skript `_poly2d()`).
5. **`IfcWallStandardCase` vs. `IfcWall`**: laut Allplan-Hilfe wird das für die
   Objekterkennung ausgewertet — gerade Wände als `IfcWallStandardCase`, alles andere
   (rund, freiform, "Elementwand") als `IfcWall`. `root.create_entity(file,
   ifc_class="IfcWallStandardCase", ...)` funktioniert direkt.
6. **Geschosszuordnung**: Allplan-Hilfe erwähnt "Geschosszuordnung ... nur beim Export,
   standardmässig deaktiviert" — für den Import selbst keine explizite Aussage gefunden,
   ob/wie `IfcBuildingStorey`-Elevationen automatisch auf Allplan-Geschosse gemappt
   werden (neue Geschosse anlegen vs. an vorhandene andocken). **Offene Frage.**
7. **Koordinatensystem/Site-Placement**: In diesem Recherche-Umfang nicht vertieft
   geprüft (`IfcSite.RefLatitude/RefLongitude/RefElevation` bzw.
   `IfcMapConversion`/`IfcProjectedCRS` für Georeferenzierung) — falls das Projekt eine
   Georeferenzierung braucht, muss das gesondert recherchiert werden (Modul
   `ifcopenshell.api.georeference` existiert laut `ls api/`, aber nicht gelesen).

## J. Validierung

- `ifcopenshell.validate.validate(f: Union[ifcopenshell.file, str], logger, express_rules:
  bool=False) -> None` — offline, kein Server/Internet nötig. Docstring empfiehlt, den
  **Dateipfad** statt eines bereits geparsten `file`-Objekts zu übergeben, damit auch
  interne C++-Parser-Fehler mitgeloggt werden.
- Logger: `ifcopenshell.validate.json_logger()` sammelt Ergebnisse in `logger.statements`
  (Liste von Dicts: `level`, `message`, `type`, `instance`, `attribute`). Alternativ ein
  Standard-`logging.Logger`.
- `express_rules=True` prüft zusätzlich die WHERE-Regeln des EXPRESS-Schemas (genau das
  hat im Verifikationslauf den Material- und Profil-Fehler gefunden) — für den Test-Loop
  dieses Projekts empfehlenswert, **immer mit `express_rules=True`** zu validieren, sonst
  werden Struktur-, aber keine Konsistenzfehler gefunden.
- CLI-Alternative dokumentiert: `python -m ifcopenshell.validate /path/to/model.ifc
  --rules --json`.

---

## Verifikation (Probe-Skript, wörtliche Ausgabe)

Skript: `/tmp/claude-0/.../scratchpad/ifc_probe.py` (nicht im Repo). Baut 1 Geschoss,
1 Wand (mit Achse, WallType+LayerSet+LayerSetUsage, Pset_WallCommon), 1 Bodenplatte
(mit Lochkontur via manuellem Voids-Workaround), 1 Öffnung (Nische, 0.1 m tief in
0.2 m dicker Wand) in IFC4, schreibt die Datei, liest sie erneut, prüft Geometrie
und validiert.

**Erster Lauf** (mit der ungefixten High-Level-API für Material und Profil-Voids —
zeigt die zwei echten Stolpersteine #2 und #3 oben):

```
WROTE .../probe.ifc
by_type IfcWallStandardCase: ['Wand-1']
by_type IfcSlab: ['Bodenplatte-1']
by_type IfcOpeningElement: ['Nische-1']
by_type IfcBuildingStorey: [('EG', 0.0)]
wall verts count: 16 bbox: [0. 0. 0.] [4.  0.2 2.5]
slab verts count: 16 bbox: [0. 0. 0.] [4.  4.  0.3]
validation statements: [
  {'level': 'error', 'message': 'With attribute:\n    <attribute CoordList: <list [1:?] of <list [3:3] of <type IfcLengthMeasure: <real>>>>>\nValue:\n    (0.0, 0.0)\nNot valid\n', 'type': 'schema', 'instance': #54=IfcCartesianPointList3D(((0.,0.),(4000.,0.),(4000.,4000.),(0.,4000.),(0.,0.))), 'attribute': 'CoordList'},
  {'level': 'error', 'message': "(outercurve.Dim == 2)\n\nViolated by:\n    (3 == 2)\n     +  where 3 = #55=IfcIndexedPolyCurve(#54,$,$).Dim\n\nOn instance:\n    #58=IfcArbitraryProfileDefWithVoids(.AREA.,'Bodenplatte-1-Kontur',#55,(#57))\n", 'type': 'entity_rule', 'instance': #58=IfcArbitraryProfileDefWithVoids(.AREA.,'Bodenplatte-1-Kontur',#55,(#57)), 'attribute': 'IfcArbitraryClosedProfileDef.WR1'},
  {'level': 'error', 'message': "(sizeof([temp for temp in usedin(SELF, 'ifc4.ifcrelassociates.relatedobjects') if 'ifc4.ifcrelassociatesmaterial' in typeof(temp) and 'ifc4.ifcmateriallayersetusage' in typeof(temp.RelatingMaterial)]) == 1)\n\nViolated by:\n    (0 == 1)\n     +  where 0 = sizeof([])\n\nOn instance:\n    #19=IfcWallStandardCase('1FsHdMte53sOrC8ewkO7N7',$,'Wand-1',$,$,#44,#30,$,.SOLIDWALL.)\n", 'type': 'entity_rule', 'instance': #19=IfcWallStandardCase('1FsHdMte53sOrC8ewkO7N7',$,'Wand-1',$,$,#44,#30,$,.SOLIDWALL.), 'attribute': 'IfcWallStandardCase.HasMaterialLayerSetUsage'}
]
```

**Zweiter Lauf** (nach den beiden Workarounds: manuelle 2D-Voids-Kontur, `IfcWallType`
+ `IfcMaterialLayerSetUsage` an der Instanz) — sauber:

```
WROTE .../probe.ifc
by_type IfcWallStandardCase: ['Wand-1']
by_type IfcSlab: ['Bodenplatte-1']
by_type IfcOpeningElement: ['Nische-1']
by_type IfcBuildingStorey: [('EG', 0.0)]
wall verts count: 16 bbox: [0. 0. 0.] [4.  0.2 2.5]
slab verts count: 16 bbox: [0. 0. 0.] [4.  4.  0.3]
validation statements: []
```

Fazit: Das Grundgerüst (A, B, C ohne Material, D-Extrusion, F) funktioniert mit den in
diesem Dokument zitierten High-Level-API-Funktionen direkt. Für D (Lochkontur) und C
(Wandmaterial) sind die oben beschriebenen Workarounds/Zusatzschritte nötig, um ein
laut `ifcopenshell.validate(express_rules=True)` **schema-konformes** IFC4 zu erhalten.
Ob Allplan 2026 die schema-verletzte erste Variante dennoch anstandslos importiert hätte
oder mit Fehlermeldung ablehnt, wurde **nicht** getestet (kein Allplan in dieser
Linux-Session verfügbar) — Empfehlung: für den Produktcode immer die validierte
(zweite) Variante verwenden.

---

## Offene Fragen an den Auftraggeber

1. **Einheiten**: Millimeter oder Meter als Projekteinheit? Es gibt keine harte Quelle,
   dass eine der beiden Varianten in Allplan 2026 "sauberer" importiert — beide sollten
   laut Allplan-Hilfe funktionieren, da Allplan die Header-Einheit selbst ausliest. Falls
   der Auftraggeber schon Erfahrungswerte mit Allplan-2026-IFC-Import hat (z.B. aus
   früheren Projekten), bitte mitteilen.
2. **Axis-Representation zwingend?** Ist bei Allplan 2026 eine Model/Axis- bzw.
   Plan/Axis-Repräsentation für Wände/Stützen Voraussetzung, damit sie NICHT als
   `IfcBuildingElementProxy` importiert werden, oder reicht eine reine
   Body/SweptSolid-Repräsentation? Keine Allplan-Quelle dazu gefunden, die das explizit
   für den Import (nicht nur Export) bestätigt.
3. **Geschosszuordnung beim Import**: Legt Allplan 2026 beim IFC-Import automatisch neue
   Geschosse in der Bauwerksstruktur an (basierend auf `IfcBuildingStorey.Elevation`
   und `Name`), oder muss der Anwender Geschosse manuell zuordnen/mappen? Die zitierte
   Allplan-Hilfeseite beschreibt "Geschosszuordnung" nur als Export-Option.
4. **Nur Version 2023-0 der Allplan-Hilfe gefunden** (help.allplan.com/Allplan/2023-0/...);
   keine 2026-spezifische Version des "IFC Import Settings"-Hilfetexts abgerufen. Falls
   sich das Mapping-Verhalten zwischen 2023 und 2026 geändert hat, bräuchte es eine
   Bestätigung durch den Auftraggeber (z.B. Screenshot der 2026-Hilfe oder Testimport).
5. **Koordinatensystem/Georeferenzierung** (`IfcSite`-Placement, `IfcMapConversion`) wurde
   nicht vertieft recherchiert, da im Auftrag nicht explizit gefordert — falls das
   Rohbaumodell an eine Landeskoordinate gebunden werden muss, bitte das als eigene
   Anforderung nachreichen, dann wird `ifcopenshell.api.georeference` gezielt geprüft.
6. ~~`IfcRectangleProfileDef`/`IfcCircleProfileDef` für Stützen~~ — geklärt:
   `ifcopenshell.api.profile.add_parameterized_profile(file, ifc_class=...)` existiert,
   ist aber laut eigenem Docstring nur ein dünner Wrapper um `file.create_entity` (siehe
   Abschnitt E).
