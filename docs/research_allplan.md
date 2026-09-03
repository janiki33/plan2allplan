# Recherche Allplan 2026 PythonParts-API (Rohbaumodell aus Architektenplänen)

Agent: `research-allplan` · Datum: 2026-09-03 · Allplan-Version: **2026**

**Quellenlage.** Alle Symbole in diesem Bericht wurden in dieser Session gelesen aus:

* API-Referenz `https://pythonparts.allplan.com/2026/api_reference/InterfaceStubs/<Modul>/<Klasse>/`
  und Manual `https://pythonparts.allplan.com/2026/manual/...` (Volltext über den
  Such-Index `https://pythonparts.allplan.com/2026/search/search_index.json` verifiziert).
* Offizielle Beispiele, Branch `2026`, lokaler Klon (HEAD `e816b12`):
  `/tmp/claude-0/-home-user-plan2allplan/cec3c10c-725f-583f-94fd-2cc650e8bb6c/scratchpad/PythonPartsExamples`
  – im Folgenden **`EX/`** (Unterordner `PythonPartsExampleScripts/` und `Library/`).
* SDK-Repo-Klon `.../scratchpad/pythonparts-sdk` (nur Ordnerstruktur `Library/`,
  `PythonPartsScripts/`, `PythonPartsActionbar/`, `install-config.yml`).

**Allplan-Stubs liegen in dieser Linux-Session NICHT vor.** Symbole, die nur in den
Framework-Ordnern der Installation existieren (`etc\PythonPartsFramework\...`), sind unten
ausdrücklich als *nicht gelesen* markiert und stehen NICHT in `evidence_allplan.md`.

Jedes empfohlene Symbol steht mit Quelle und Signatur in `docs/evidence_allplan.md`.

---

## Zusammenfassung vorab (die drei tragenden Erkenntnisse)

1. **`AllplanArchElements.PlaneReferences` ist das zentrale Höhenobjekt.** Es trägt
   Unterkante *und* Oberkante **unabhängig voneinander**, jeweils mit
   `BottomPlaneDependency` / `TopPlaneDependency` (Enum `PlaneReferenceDependency` mit
   `eAbsElevation | eBottomPlane | eTopPlane | eComponentsBottomPlane | eComponentsTopPlane |
   eTopFixed | eBottomFixed`) und einem Offset (`BottomOffset` / `TopOffset`).
   **Die gemischte Anbindung (unten Ebene + Offset, oben Absolutkote) ist damit auf
   Objektebene direkt abbildbar** – ein einziges Objekt, keine Tricks.
2. **Alle Rohbau-Bauteile werden als native Allplan-Architekturobjekte erzeugt**
   (`WallElement`, `ColumnElement`, `SlabElement`, `SlabFoundationElement`,
   `GeneralOpeningElement`, `SlabOpeningElement`) und einfach in die `ModelEleList` bzw.
   `CreateElementResult` gelegt – **nicht** in einen PythonPart-Container gepackt. Damit
   sind sie nativ editierbar. Das offizielle Wall-Beispiel macht genau das
   (`EX/PythonPartsExampleScripts/ArchitectureExamples/Objects/Wall.py:121`).
3. **Die Allplan-Bauwerksstruktur (Geschossliste, Ebenennamen, Geschosshöhen) ist über die
   Python-API NICHT lesbar.** Es gibt keine Klasse `BuildingStructure`, `Storey` o. ä. in
   `NemAll_Python_*`. Lesbar sind nur (a) die Default-Ebenen des *aktuellen Teilbilds*
   (`BottomTopPlaneService.GetDocumentDefaultPlanes(doc)`), (b) die aufgelösten
   Absolutkoten einer `PlaneReferences`, (c) Teilbildnummern/-namen. → siehe **E** und die
   offenen Fragen.

---

## A. Wand erzeugen

### Klassen und Signaturen

| Symbol | Signatur |
|---|---|
| `NemAll_Python_ArchElements.WallProperties` | `__init__()` / `__init__(wallProp: WallProperties)` |
| `WallProperties.Axis` | `AxisProperties` (writable) |
| `WallProperties.TierCount` | `int` (writable) – Anzahl Schichten |
| `WallProperties.StartNewJoinedWallGroup` | `bool` (writable) |
| `WallProperties.GetWallTierProperties` | `GetWallTierProperties(tierIndex: int) -> WallTierProperties` – **Achtung: Index beginnt bei 1** (so in der API-Referenz dokumentiert) |
| `WallTierProperties` | `Bases: ArchBaseProperties`; zusätzlich `Thickness: float` |
| `WallElement` | `__init__(wallProp: WallProperties, axis: object)` – `axis` ist `Line2D`, `Arc2D` oder eine beliebige 2D-Kurve (Manual „Primary components") |
| `AxisProperties` | `Distance: float`, `Extension: int`, `Modus: int`, `OnTier: int`, `Position: int` |
| `WallAxisPosition` | Enum `eLeft=1`, `eCenter=2`, `eRight=4`, `eFree=8`, `eUnknown` |

Höhen/Material/Name kommen aus der Basisklasse **`ArchBaseProperties`** (siehe F):
`PlaneReferences: PlaneReferences`, `Material: str`, `Name: str`, `Surface: str`,
`Priority: int`, `Trade: int`, `CalculationMode: int`, `Factor: float`,
`CommonProperties`, `SurfaceElementProperties`.

### Beispiel (vollständig gelesen)

`EX/PythonPartsExampleScripts/ArchitectureExamples/Objects/Wall.py`

```python
# Zeilen 158–197
wall_prop = AllplanArchElements.WallProperties()
wall_prop.Axis                    = self.axis_properties
wall_prop.TierCount               = self.build_ele.TierCount.value
wall_prop.StartNewJoinedWallGroup = True
for tier_index in range(wall_prop.TierCount):
    wall_tier_prop = wall_prop.GetWallTierProperties(tier_index + 1)   # tier indices starts with 1!
    wall_tier_prop.PlaneReferences = self.build_ele.PlaneReferences.value[tier_index]
    wall_tier_prop.Thickness       = self.build_ele.Thickness.value[tier_index]
    wall_tier_prop.CommonProperties = self.build_ele.CommonProp.value[tier_index]
```

```python
# Zeilen 238–248
def wall_element(self, axis: AllplanGeometry.Line2D) -> AllplanArchElements.WallElement:
    return AllplanArchElements.WallElement(self.wall_properties, axis)
```

```python
# Zeilen 119–122 – Rückgabe als natives Element, KEIN PythonPart-Container
_, axis = AllplanGeometry.ConvertTo2D(self.axis_input_result.input_line)
return CreateElementResult([self.wall_element(axis)],
                           placement_point = AllplanGeometry.Point2D())
```

**Wichtig:** `PlaneReferences` ist **pro Wandschicht** (Tier) gesetzt, nicht pro Wand.
Bei einschaligem Rohbau also `TierCount = 1` und `GetWallTierProperties(1)`.

### Höhenanbindung (Kern der Aufgabe)

`NemAll_Python_ArchElements.PlaneReferences`, Konstruktoren:

```
__init__(doc: DocumentAdapter, refElement: BaseElementAdapter)   # Default-Ebenen des Teilbilds
__init__(element: PlaneReferences)                               # Copy-Konstruktor
```

Getter/Setter (alle in der API-Referenz gelesen):

```
GetBottomElevation() -> float          SetBottomElevation(elevation: float)
GetAbsBottomElevation() -> float       SetAbsBottomElevation(absElevation: float)
GetBottomOffset() -> float             SetBottomOffset(offset: float)
GetBottomPlaneDependency() -> PlaneReferenceDependency
                                       SetBottomPlaneDependency(dependency: PlaneReferenceDependency)
GetBottomReferencePlane() -> ReferencePlaneID
                                       SetBottomReferencePlane(bottomReferencePlane: ReferencePlaneID)
GetBottomDirection() -> Direction      SetBottomDirection(direction: Direction)
GetBottomPlaneSurface() -> Any         SetBottomPlaneSurface(bottomSurface: object)
                                       SetBottomSurfacePlaneElement(surfacePlane: BaseElementAdapter)
                                       SetBottomToBottom(planeRef: PlaneReferences)
                                       SetBottomToTop(planeRef: PlaneReferences)
… identisch für Top …
GetHeight() -> float                   SetHeight(height: float)
GetMaximumHeight() -> float            SetMaximumHeight(maximumHeight: float)
GetDocument() -> DocumentAdapter       SetDocument(doc: DocumentAdapter)
GetReferenceElement() -> BaseElementAdapter
                                       SetReferenceElement(refElement: BaseElementAdapter)
                                       SetElementToPlaneModeling(elementToPlaneModeling: ElementToPlaneModeling)
```

Alle Getter existieren zusätzlich als **writable Properties** (`AbsBottomElevation`,
`BottomOffset`, `BottomPlaneDependency`, `BottomReferencePlane`, `Height`, …).

Verschachtelte Enums (API-Referenz, wörtlich):

* `PlaneReferences.PlaneReferenceDependency`:
  `eAbsElevation`, `eBottomPlane`, `eTopPlane`, `eComponentsBottomPlane`,
  `eComponentsTopPlane`, `eTopFixed`, `eBottomFixed`
* `PlaneReferences.Direction`: `eParallel`, `eOrthogonal`
* `PlaneReferences.ElementToPlaneModeling`: `eFitToPlane`, `eLowerCutToPlane`, `eUpperCutToPlane`

Die entscheidende Doku-Aussage (API-Referenz, Property `BottomOffset`, wörtlich):

> „Offset between the reference plane and the bottom edge of an architectural component.
> **If the property `BottomPlaneDependency` is set to `eAbsElevation`, this is the absolute
> elevation of the bottom edge.**"

Analog für `TopOffset`. **Damit ist beides mit demselben Feld abgebildet:** ist die
Dependency eine Ebene, ist `*Offset` der Offset zur Ebene; ist sie `eAbsElevation`, ist
`*Offset` die Absolutkote.

**Mischform auf Objektebene: ja, direkt möglich.** Bottom und Top sind vollständig
getrennte Feldgruppen. Muster für „unten Geschoss-Unterkante + 0 mm, oben Absolutkote":

```python
pr = AllplanArchEle.PlaneReferences(doc, AllplanEleAdapter.BaseElementAdapter())
pr.SetBottomPlaneDependency(AllplanArchEle.PlaneReferences.PlaneReferenceDependency.eBottomPlane)
pr.SetBottomOffset(0.0)
pr.SetTopPlaneDependency(AllplanArchEle.PlaneReferences.PlaneReferenceDependency.eAbsElevation)
pr.SetTopOffset(2_450.0)     # Absolutkote in mm
```

> ⚠️ **Nicht praktisch verifizierbar** in dieser Session (kein Allplan). Die
> Enum-Bedeutungen `eComponentsBottomPlane` / `eComponentsTopPlane` / `eTopFixed` /
> `eBottomFixed` sind in der Referenz **nicht beschrieben** (nur die Namen). Siehe offene
> Fragen O-1.

Welche Ebene konkret referenziert wird, steuert `ReferencePlaneID`
(`NemAll_Python_ArchElements.ReferencePlaneID`, struct):

```
__init__() / __init__(modelGuid: GUID, planeId: int) / __init__(element: ReferencePlaneID)
ModelGuid : GUID (writable)      PlaneId : int (read-only property)
IsDefaultLowerPlane() -> bool    IsDefaultUpperPlane() -> bool
IsDocumentRefSurface() -> bool   IsInModel() -> bool     IsValid() -> bool
SetCustomLowerPlane()            SetCustomUpperPlane()   Invalidate()
```

`IsDefaultLowerPlane()`/`IsDefaultUpperPlane()` beziehen sich auf die **Standard-Ebenen**
(untere/obere Regelebene) des Teilbilds – genau das, was die Bauwerksstruktur je Geschoss
setzt. Ein *anderer* Ebenensatz (z. B. Ebene eines anderen Geschosses) wäre über
`ModelGuid` + `PlaneId` adressierbar; **wie man diese IDs bekommt, ist nicht dokumentiert**
(offene Frage O-2).

### Auflösen von Ebene → Absolutkote

`NemAll_Python_ArchElements.BottomTopPlaneService` (statische Methoden):

```
GetAbsoluteBottomElevation(refElement: BaseElementAdapter, doc: DocumentAdapter,
                           planeProp: BasePlaneReferences) -> float
GetAbsoluteTopElevation   (…) -> float
GetDocumentBottomElevation(…) -> float
GetDocumentTopElevation   (…) -> float
GetBottomReferencePlane(refElement, doc, planeProp) -> BRep3D | Polyhedron3D | Plane3D
GetTopReferencePlane   (…) -> BRep3D | Polyhedron3D | Plane3D
GetDocumentDefaultPlanes(doc: DocumentAdapter) -> tuple[Plane3D, Plane3D]
```

Beispiele: `EX/PythonPartsExampleScripts/ServiceExamples/BottomTopPlaneService.py:275–293`
und `EX/PythonPartsExampleScripts/BasisExamples/General/PlaneConnection.py:162–165`.

### Stolpersteine A

* Wand-Tier-Index ist **1-basiert** (`GetWallTierProperties(tierIndex)`, Doku: „First tier
  has the index 1!"), Slab-Tier-Index im Beispiel **0-basiert** (`range(TierCount)`) →
  inkonsistent, siehe C/Stolpersteine.
* `AxisProperties.Extension` hat **Default 0 und muss zwingend auf 1 oder -1 gesetzt
  werden** (API-Referenz wörtlich: „IMPORTANT: Default value is 0 and must be changed to
  either 1 or -1!"). Sonst entsteht die Wand nicht auf der erwarteten Seite.
* `AxisProperties.Distance` muss im Bereich `<0.0, component_width>` liegen (API-Referenz).
* `StartNewJoinedWallGroup = True` verhindert das automatische Verbinden mehrerer Wände
  zu einer Gruppe (Kommentar in `Wall.py:166`). Für ein Plan-Import-Werkzeug, das viele
  Einzelwände absetzt, ist `True` je Wand die sichere Wahl.

---

## B. Stütze (rechteckig / rund)

### Klassen

| Symbol | Signatur |
|---|---|
| `ColumnProperties` | `Bases: VerticalElementProperties, ArchBaseProperties` |
| `ColumnElement` | `__init__(columnProp: ColumnProperties, placementPoint: object)`; `PlacementPoint: Point2D`; `SetCommonProperties(commonProp: CommonProperties)` |
| `VerticalElementProperties` | `ShapeType: ShapeType`, `Width: float`, `Depth: float`, `Radius: float`, `Angle: Angle`, `ShapePolygon: Polygon2D`, `ProfileFullName: str`; Methoden `SetSize`, `SetCornerRadius`, `SetAttribute` |
| `ShapeType` (Enum) | `eRectangular`, `eCircular`, `ePolygonal`, `eProfile`, `eArbitrary=6`, `eChamfer`, `eConical`, `eRegularPolygonInscribed`, `eRegularPolygonCircumscribed`, `eRiseBottomTop`, `eStep`, `eUnknown` |

Höhenanbindung **identisch zu A**: `column_prop.PlaneReferences = <PlaneReferences>`
(ererbt aus `ArchBaseProperties`).

### Beispiel

`EX/PythonPartsExampleScripts/ArchitectureExamples/Objects/Column.py`

```python
# Zeilen 169–173
column_prop = AllplanArchEle.ColumnProperties()
column_prop.PlaneReferences = self.build_ele.PlaneReferences.value
self.shape_geo_param_util.create_shape_geo_properties(self.build_ele, column_prop, …)
```

```python
# Zeilen 214–216
return AllplanArchEle.ColumnElement(self.create_column_properties(), input_point)
```

> `ShapeGeometryPropertiesParameterUtil` (`ParameterUtils.ShapeGeometryPropertiesParameterUtil`)
> und der Parameter-Include `etc\PythonPartsFramework\ParameterIncludes\ShapeGeometryProperties.incl`
> liegen **nicht** im Beispiel-Repo, sondern nur in der Allplan-Installation
> (`Column.pyp:29`). Für unser Werkzeug ist er entbehrlich: die Felder `ShapeType`,
> `Width`, `Depth`, `Radius`, `Angle` lassen sich direkt auf `ColumnProperties` setzen
> (dokumentiert in `VerticalElementProperties`).

**Alternative Stütze mit expliziter Höhenanbindung:**
`StructuralColumnProperties` / `StructuralColumnElement`
(`EX/PythonPartsExampleScripts/StructuralFramingExamples/StructuralColumn.py:54–115`):

```python
columnProps = AllplanArchElements.StructuralColumnProperties()
columnProps.SetProfileShapeProperties(AllplanArchElements.RectangularShape())  # oder CircularShape/ProfileShape
columnProps.SetProfileAngle(angle)
columnProps.SetCommonProperties(commonProps)
columnProps.SetMaterial(build_ele.Material.value)
columnProps.SetPosition(0, 0, 0)
columnProps.SetHeightProperties(doc, build_ele.ColumnPlaneReferences.value)
columnProps.SetAnchorPointProperties(anchor, build_ele.Offset.value)
columnProps.SetAnglesAtStart(angleX, angleY);  columnProps.SetAnglesAtEnd(angleX, angleY)
column = AllplanArchElements.StructuralColumnElement(columnProps)
column.SetAxisVisibility(build_ele.ShowAxis.value)
```

`RectangularShape.Width/.Thickness`, `CircularShape.Radius`, `ProfileShape.ProfilePath`.

**Empfehlung:** für ein Architektur-Rohbaumodell die **architektonische `ColumnElement`**
verwenden (gleiche Ebenenlogik wie Wand/Decke, gleiche Attributbasis). `StructuralColumn*`
gehört zur Tragwerks-Bauteilfamilie (anderer Objekttyp, anderer Anwendungsbereich) und
verlangt zusätzlich eine gültige Lokalisierungsdatei für den Ankerpunkt
(`StructuralColumn.py:91–100`: ohne Localisation wird keine Geometrie erzeugt).

---

## C. Decke, Bodenplatte, Löcher

### Klassen

| Symbol | Signatur |
|---|---|
| `SlabProperties` | `Bases: ArchBaseProperties`; `TierCount: int`, `VariableTier: int`, `GetSlabTierProperties(tierIndex: int) -> SlabTierProperties`, `SetAttribute` |
| `SlabTierProperties` | `Bases: ArchBaseProperties`; `Thickness: float` |
| `SlabElement` | `__init__(slabProp: SlabProperties, slabPolygon: Polygon2D)`; `Properties`, `GetProperties()`, `SetProperties(SlabProp)` |
| `SlabFoundationProperties` | `Bases: SlabProperties, ArchBaseProperties` |
| `SlabFoundationElement` | `Bases: SlabElement, …`; `__init__(slabFoundProp: SlabFoundationProperties, slabPolygon: Polygon2D)` |

### Beispiele

`EX/…/ArchitectureExamples/Objects/Slab.py:169–195`:

```python
slab_prop = AllplanArchElements.SlabProperties()
slab_prop.PlaneReferences = self.build_ele.PlaneReferences.value
slab_prop.TierCount       = self.build_ele.TierCount.value
slab_prop.VariableTier    = self.build_ele.VariableTier.value
for tier_index in range(slab_prop.TierCount):
    slab_tier_prop           = slab_prop.GetSlabTierProperties(tier_index)   # 0-basiert!
    slab_tier_prop.Thickness = self.build_ele.Thickness.value[tier_index]
```
`Slab.py:211`: `AllplanArchElements.SlabElement(self.slab_properties, outline)`
`SlabFoundation.py:211`: `AllplanArchElements.SlabFoundationElement(self.slab_properties, outline)`

Interessant für die Höhenlogik (`Slab.py:245–258`): das Beispiel koppelt Schichtdicken und
`PlaneReferences.SetHeight()`, d. h. bei einer Decke ist die Gesamtdicke = Summe der
Tier-Dicken = `PlaneReferences.Height`.

### Höhenanbindung UK/OK

Wie A: `SlabProperties.PlaneReferences` mit unabhängigen Bottom/Top-Dependencies.
Für „UK Decke = OK Geschoss, OK Decke = UK Geschoss darüber" gibt es **zwei belegte Wege**:

1. **Über Dependencies:** `SetBottomPlaneDependency(eBottomPlane)` + `SetBottomOffset(...)`
   und `SetTopPlaneDependency(eTopPlane)` + `SetTopOffset(...)`, jeweils bezogen auf die
   Standard-Ebenen des Teilbilds. Welches Teilbild welche Ebenen hat, kommt aus der
   Bauwerksstruktur (siehe E) – d. h. es muss das *richtige* Teilbild aktiv sein.
2. **Über eine Quell-`PlaneReferences`:** `SetBottomToTop(planeRef)` bzw.
   `SetTopToBottom(planeRef)` übernehmen die Unter-/Oberkante eines anderen
   `PlaneReferences`-Objekts. Damit kann man z. B. die OK einer Wand direkt an die UK der
   darüberliegenden Decke koppeln, ohne Ebenen-IDs zu kennen.

`SlabOpening.py:157–159` zeigt das Lesen aus einem bestehenden Bauteil:

```python
slab_ele = cast(AllplanArchEle.SlabElement, AllplanBaseEle.GetElement(self.slab_adapter_ele))
self.slab_plane_ref = slab_ele.Properties.PlaneReferences
self.build_ele.HeightSettings.value = AllplanArchEle.PlaneReferences(self.slab_plane_ref)
```

### Löcher / Rücksprünge in der Decke

**`SlabElement` nimmt nur ein einfaches `Polygon2D` entgegen – keine Löcher, kein
`PolygonalArea2D`** (API-Referenz `SlabElement.__init__`, wörtlich geprüft; auch
`SlabFoundationElement` identisch). Löcher werden **als eigene Sekundärobjekte** modelliert:
`SlabOpeningElement` (siehe D). Das entspricht auch der nativen Allplan-Bedienung.

→ Für unser Werkzeug bedeutet das: **Deckenkontur = Aussenpolygon; jedes Loch, jede
Aussparung und jeder Rücksprung ist ein separates `SlabOpeningElement`.**

### Bodenplatte

`SlabFoundationElement` (Allplan: „Fundamentplatte"), API-identisch zur Decke plus
`SlabFoundationProperties`. **Neu in 2026** (Release Notes „WIP-3": „With the newly exposed
class `SlabFoundationElement` it is now possible to create and modify slab foundation
using Python API.") → in 2025 nicht verfügbar, siehe I.

---

## D. Aussparungen / Durchbrüche

### Wand: `GeneralOpeningElement`

```
GeneralOpeningProperties.__init__(openingType: OpeningType)
GeneralOpeningProperties.__init__(openingProp: GeneralOpeningProperties)
  .PlaneReferences          : PlaneReferences   (writable)
  .OpeningType              : OpeningType       (writable)
  .Independent2DInteraction : bool
  .VisibleInViewSection3D   : bool   # False => Öffnung schneidet das 3D-Modell NICHT (nur bei Recess)
  .GetGeometryProperties()      -> VerticalOpeningGeometryProperties
  .GetSillProperties()          -> VerticalOpeningSillProperties
  .GetOpeningSymbolsProperties()-> OpeningSymbolsProperties

OpeningType (Enum): eNiche = 0   # Nische (nicht durchgehend)
                    eRecess = 1  # Aussparung/Durchbruch (durchgehend)

VerticalOpeningGeometryProperties:
  Width: float, Depth: float, Shape: VerticalOpeningShapeType,
  ShapePolygon: Polygon2D, ProfilePath: str,
  RiseAtTop/RiseAtBottom: float, SegmentsAtTop/SegmentsAtBottom: int

GeneralOpeningElement.__init__(wallOpeningProp, generalEle: BaseElementAdapter,
                               startPnt: Point2D, endPnt: Point2D,
                               drawPlacementPreview: bool)
GeneralOpeningElement.__init__(wallOpeningProp, generalEle: BaseElementAdapter,
                               groundPlanePolygon: Polygon2D,
                               drawPlacementPreview: bool)   # polygonale Öffnung
```

Beispiel `EX/…/ArchitectureExamples/Objects/GeneralOpening.py:118–149`:

```python
opening_prop = AllplanArchEle.GeneralOpeningProperties(
    AllplanArchEle.OpeningType.eNiche if build_ele.NicheType.value == "Niche"
    else AllplanArchEle.OpeningType.eRecess)
opening_prop.VisibleInViewSection3D   = build_ele.IsVisibleInViewSection3D.value
opening_prop.Independent2DInteraction = build_ele.HasIndependent2DInteraction.value
opening_prop.PlaneReferences          = build_ele.HeightSettings.value
…
opening_ele = AllplanArchEle.GeneralOpeningElement(opening_prop, self.placement_ele,
                                                   self.opening_start_pnt.To2D,
                                                   self.opening_end_pnt.To2D,
                                                   build_ele.InputMode.value == build_ele.ELEMENT_SELECT)
```

Polygon-Variante: `EX/…/ArchitectureExamples/Objects/GeneralOpeningsFor3DSolids.py:340`
`AllplanArchEle.GeneralOpeningElement(opening_prop, opening_parent_ele, opening_polygon, False)`

**Höhe: Ebene oder Absolut?** – Beides, denn `GeneralOpeningProperties.PlaneReferences` ist
dasselbe `PlaneReferences`-Objekt wie bei Wand/Decke. Im `.pyp` heisst der Parameter
`HeightSettings`, ist aber `<ValueType>PlaneReferences</ValueType>` mit
`<ValueDialog>PlaneReferences</ValueDialog>`
(`EX/Library/Examples/PythonParts/ArchitectureExamples/Objects/GeneralOpening.pyp:106–113`).
Für Fenster-/Türhöhen ist also eine Absolutkote über
`TopPlaneDependency = eAbsElevation` + `TopOffset = <Kote>` möglich.

**Durchgehend vs. Nische:**
* Nische → `OpeningType.eNiche` und `GetGeometryProperties().Depth = <Nischentiefe>`.
* Durchgehend → `OpeningType.eRecess`; im Beispiel-`.pyp` hat `Depth` den Default `0`
  mit `MaxValue = ElementThickness` (`GeneralOpening.pyp:71–78`) – `Depth = 0` bedeutet
  „volle Bauteildicke". In `GeneralOpeningsFor3DSolids.py:333` wird `Depth` explizit auf
  `AxisElementAdapter(parent).GetThickness()` gesetzt.
  > ⚠ Die Semantik `Depth == 0` ⇒ durchgehend ist aus dem `.pyp`-Default und den
  > Beispielen abgeleitet, **nicht** in der API-Referenz beschrieben (offene Frage O-3).

### Decke: `SlabOpeningElement`

```
SlabOpeningProperties.__init__(openingType: SlabOpeningType = eOpening)
  Bases: VerticalElementProperties, ArchBaseProperties
  .PlaneReferences (aus ArchBaseProperties), .Independent2DInteraction: bool
  .GetOpeningType() -> SlabOpeningType
  .GetOpeningSymbolsProperties() -> OpeningSymbolsProperties
  Form/Grösse über VerticalElementProperties: ShapeType, Width, Depth, Radius, ShapePolygon

SlabOpeningType (Enum): eOpening = 0   # durchgehende Öffnung
                        eRecess  = 1   # Vertiefung (nicht durchgehend)

SlabOpeningElement.__init__(slabOpeningProp, placementPoint: Point2D|Point3D,
                            slabConnectionUUID: GUID)
```

Beispiel `EX/…/ArchitectureExamples/Objects/SlabOpening.py:217–235`:

```python
opening_type  = AllplanArchEle.SlabOpeningType.eOpening if build_ele.OpeningType.value == "Opening" \
                else AllplanArchEle.SlabOpeningType.eRecess
opening_props = AllplanArchEle.SlabOpeningProperties(opening_type)
…
opening_props.PlaneReferences = build_ele.HeightSettings.value
opening_props.CommonProperties = self.common_prop
opening_ele = AllplanArchEle.SlabOpeningElement(
    opening_props,
    self.placement_pnt.To2D - self.shape_geo_param_util.get_reference_point(build_ele),
    self.slab_adapter_ele.GetModelElementUUID())
```

Im `.pyp` sind die Höheneinstellungen **nur bei `eRecess` aktiv**
(`SlabOpening.pyp:36–61`: `<ConditionGroup><Enable>OpeningType != "Opening"</Enable>`) –
bei `eOpening` gehen sie automatisch durch die ganze Decke.

### 🔴 Der wichtigste Stolperstein der ganzen Recherche

**Öffnungen brauchen ein bereits in der Datenbank existierendes Elternbauteil.** Beide
Öffnungs-Konstruktoren verlangen entweder einen `BaseElementAdapter` (Wandöffnung) oder die
`GUID` des Modell-Elements (Deckenöffnung). Es gibt in den Beispielen und in der Referenz
**keine** Möglichkeit, Wand und Öffnung in einem Zug aus frisch konstruierten
Python-Objekten zu erzeugen (in allen sieben Öffnungsbeispielen wird das Elternelement
vorher per Selektion/Query ermittelt).

→ **Konsequenz für die Architektur:** das Werkzeug braucht einen **Zwei-Pass-Ablauf**:
1. Pass 1: alle Primärbauteile (Wände, Stützen, Decken) mit
   `AllplanBaseElements.CreateElements(...)` absetzen; die Funktion liefert eine
   `BaseElementAdapterList` der erzeugten Elemente zurück.
2. Pass 2: aus dieser Liste die Elternadapter (bzw. `GetModelElementUUID()`) nehmen und die
   Öffnungen erzeugen.

`CreateElements(doc, insertionMat: Matrix3D, modelEleList: list, modelUuidList: list,
assoRefObj: object, appendReinfPosNr: bool = True, createUndoStep: bool = True)
-> BaseElementAdapterList`.

Alternativ (falls in Pass 1 selektiert statt zurückgegeben wird):
`AllplanIFW.SelectElementsService.SelectByPolygon(...)` wie in
`PolygonalGeneralOpening.py:160–166`.

---

## E. Bauwerksstruktur lesen, Teilbilder

### Was NICHT geht

Der komplette Such-Index von `pythonparts.allplan.com/2026` (10 319 Dokument-Abschnitte)
enthält **kein** Symbol `BuildingStructure`, `Storey`, `BuildingLevel`, `Level`,
`HeightSettings` (als API-Klasse) o. ä. Die einzigen Treffer zu „storey" sind
`RoomProperties.StoreyCode` (ein Textattribut am Raum) und ein Manual-Satz. Die Klassenliste
von `NemAll_Python_IFW_ElementAdapter` (vollständig abgerufen) enthält nur
`ArchElementType, AssocViewElementAdapter, AxisElementAdapter, BaseElementAdapter,
BaseElementAdapterChildElementsService, BaseElementAdapterList,
BaseElementAdapterParentElementService, BaseElementAdapterService, BaseElementAdapterVector,
DocumentAdapter, DocumentNameService, ElementAdapterType, ElementAdapterTypeData,
ElementAdapterTypeGroup, GUID, PrecastPropertiesService, ReinforcementPropertiesReader`.

**Fazit: Die Geschossliste der Bauwerksstruktur (Namen, Höhen der Standard-Ebenen je
Geschoss, Zuordnung Geschoss→Teilbild) ist über die Python-API nicht auslesbar.**

### Was geht

| Aufgabe | API |
|---|---|
| Default-Ebenen des **aktuellen** Teilbilds als Geometrie | `BottomTopPlaneService.GetDocumentDefaultPlanes(doc) -> tuple[Plane3D, Plane3D]` |
| Default-`PlaneReferences` des aktuellen Teilbilds | `PlaneReferences(doc, BaseElementAdapter())` – so in `SlabOpening.py:117` und `GeneralOpeningsFor3DSolids.py:318` |
| Absolutkote UK/OK einer `PlaneReferences` auflösen | `BottomTopPlaneService.GetAbsoluteBottomElevation/​GetAbsoluteTopElevation(refElement, doc, planeProp) -> float` |
| Referenz-Ebene als Geometrie (auch schief/frei) | `BottomTopPlaneService.GetBottomReferencePlane/​GetTopReferencePlane(...) -> BRep3D \| Polyhedron3D \| Plane3D` |
| Ist die referenzierte Ebene die Standard-Ebene? | `ReferencePlaneID.IsDefaultLowerPlane() / IsDefaultUpperPlane() / IsDocumentRefSurface() / IsInModel()` |
| Aktive Teilbildnummer | `AllplanBaseElements.DrawingFileService.GetActiveFileNumber() -> int` |
| Alle geladenen Teilbilder + Ladezustand | `DrawingFileService().GetFileState() -> list[tuple[int, DrawingFileLoadState]]` |
| Teilbildname lesen/ändern | `DrawingFileService.GetDrawingFileName(nr) -> tuple[bool,str]`, `RenameDrawingFile(nr, name) -> bool` |
| Teilbild **aktiv im Vordergrund** setzen (= dorthin absetzen) | `DrawingFileService().LoadFile(doc, fileIndex: int, loadState: DrawingFileLoadState)`, z. B. `DrawingFileLoadState.ActiveForeground`; vorher ggf. `UnloadAll(doc)` |
| Teilbild-Auswahldialog, **nur Teilbilder der Bauwerksstruktur** | `DrawingFileService.ShowDrawingFileDialog(doc, singleSelection: bool, deactivateDerived: bool) -> list` – Manual zum `.pyp`-ValueType `DrawingFile`: „When set to True, only the drawing files **from the building structure** are available for selection." |
| Elemente nachträglich in anderes Teilbild verschieben/kopieren | `MoveElementsToDrawingFile(doc, elements: BaseElementAdapterList, targetDrawingFiletNr: int, viewProj: ViewWorldProjection)` bzw. `CopyElementsToDrawingFile(...)` (neu, Release Notes „WIP-6") |
| Teilbildnamen ohne Service | `DocumentNameService.GetActiveDocumentName()`, `GetDocumentNameByFileNumber(...)`, `GetLoadedDocumentsNameData()` |

Beleg für den Teilbildwechsel:
`EX/PythonPartsExampleScripts/InteractorExamples/DrawingLayoutFileInteractor.py:183–192`

```python
drawing_file_serv = AllplanBaseElements.DrawingFileService()
drawing_file_serv.UnloadAll(doc)
drawing_file_serv.LoadFile(doc, build_ele.DrawingFileNumber.value,
                           AllplanBaseElements.DrawingFileLoadState.ActiveForeground)
```

und `EX/PythonPartsExampleScripts/ServiceExamples/DrawingFile_LayoutFileService.py:83–93`.

### Empfohlener Umgang im Projekt

Da die Geschossliste nicht lesbar ist, muss die **Zuordnung Geschoss → Teilbildnummer aus
der Konfiguration des Werkzeugs kommen** (oder einmalig per
`ShowDrawingFileDialog(doc, False, True)` vom Benutzer bestätigt werden). Pro Geschoss:
Teilbild via `LoadFile(..., ActiveForeground)` aktiv setzen, Bauteile mit
`PlaneReferences(doc, BaseElementAdapter())` + `eBottomPlane`/`eTopPlane` + Offsets
erzeugen – dann ziehen sie automatisch die Standard-Ebenen genau dieses Teilbilds, also die
vom Bauwerksstruktur-Geschoss gesetzten. Absolutkoten nur dort, wo die Fachlogik das
verlangt (Brüstung/Sturz).

> ⚠ **Nicht verifiziert:** ob `LoadFile(..., ActiveForeground)` mitten in einem laufenden
> PythonPart zuverlässig funktioniert und ob `CreateElements` dann tatsächlich ins neue
> aktive Teilbild schreibt. Offene Frage O-4.

---

## F. Attribute und Material

### Material als Bauteil-Eigenschaft (bevorzugt)

`ArchBaseProperties` (Basisklasse aller Architektur-Properties) hat:

```
GetMaterial() -> str        SetMaterial(material: str)        Material : str  (writable)
GetName()     -> str        SetName(name: str)                Name     : str  (writable)
GetSurface()  -> str        SetSurface(surface: str)          Surface  : str  (writable)
GetPlaneReferences() -> PlaneReferences   SetPlaneReferences(planeRef: PlaneReferences)
Priority: int, Trade: int, CalculationMode: int, Factor: float, Hatch/Pattern/Filling/
FaceStyle/BackgroundColor: int, CommonProperties, SurfaceElementProperties, Status, BitmapName
```

Das Manual („Primary components", Klassendiagramm) listet `Material` explizit als Member von
`ArchBaseProperties`. Damit gilt für Wand-Tier, Slab-Tier, Column, Beam, Öffnungen
gleichermassen: `props.Material = "C25/30"`.

`Material` ist zugleich das Allplan-Attribut **Nr. 508** (Manual
`features/model_access/read_access/#attributes`, gelesene Attributliste einer Wand:
`508 Material = …`). `Name` entspricht dem Attribut **498 `Object_name`** – nicht
zwingend, aber die Liste zeigt die Zuordnung.

### Freie Attribute (z. B. «Brüstung» / «Sturz»)

**Weg 1 – beim Erzeugen, direkt am Element** (Manual `features/attributes/element_attributes`):

```python
attr = AllplanBaseElements.AttributeString(1398, "A2")      # AttributeString(id: int, value: str)
attr_set   = AllplanBaseElements.AttributeSet([attr])       # AttributeSet(elements: list)
attributes = AllplanBaseElements.Attributes([attr_set])     # Attributes(elements: list)
model_element.SetAttributes(attributes)                     # AllplanElement.SetAttributes
```

Verfügbare Attributtypen: `AttributeString(id, value: str)`, `AttributeInteger(id, int)`,
`AttributeDouble(id, float)`, `AttributeDate`, `AttributeEnum(id, key: int)`,
`AttributeStringVec`.

**Weg 2 – über das Framework** (`BuildingElementAttributeList`, kennt die Wertetypen selbst):

```python
attribute_list = BuildingElementAttributeList()
attribute_list.add_attribute(attr_id: int, attribute_value: Any)
attribute_list.add_attribute_by_unit(attr_id, value)          # wandelt in Attributeinheit
attribute_list.add_attributes(list[tuple[int, Any]])
attribute_list.add_attributes_from_parameters(build_ele)
attribute_list.get_attribute_list() -> list[Attribute]
attribute_list.get_attributes_list_as_tuples() -> list[tuple[int, Any]]
attribute_list.set_attributes_to_element(element: AllplanElement)
```

Beispiel `EX/PythonPartsExampleScripts/BasisExamples/General/Attributes.py:109–113`:

```python
attributes_list = BuildingElementAttributeList()
attributes_list.add_attributes_from_parameters(build_ele)
model_ele_list.set_element_attributes(-1, attributes_list.get_attribute_list())
```

`ModelEleList.set_element_attributes(index: int, attributes: list[Attribute])`
(`-1` = letztes Element der Liste).

**Weg 3 – nachträglich an bestehenden Elementen:**

```
ElementsAttributeService.GetAttributes(ele: BaseElementAdapter,
                                       readState: eAttibuteReadState = ReadAll) -> list
ElementsAttributeService.ChangeAttribute(attrId, value, elements: BaseElementAdapterList,
                                         setUndefAttrib=False, setDeleteAttrib=False)
ElementsAttributeService.ChangeAttributes(attributeDataList: list[tuple[int, Any]],
                                          elements: BaseElementAdapterList,
                                          setUndefAttrib=False, setDeleteAttrib=False)
                                          -> BaseElementAdapterList
```

**Attribut-ID zu einem Namen finden / neues Benutzerattribut anlegen:**

```
AttributeService.GetAttributeID(doc: DocumentAdapter, attributeName: str) -> int    # -1 = existiert nicht
AttributeService.GetAttributeName(doc, attributeID: int) -> str
AttributeService.GetAttributeType(doc, id)     AttributeService.GetDefaultValue(doc, id)
AttributeService.GetEnumValues(doc, id)        AttributeService.GetInputListValues(doc, id)
AttributeService.AddUserAttribute(doc, type, name, defaultValue, minValue, maxValue,
                                  dim, controlType, listValues) -> int
```
(Beispiel `EX/PythonPartsExampleScripts/ServiceExamples/AttributeService.py:70–137`.)

**Empfehlung für «Brüstung»/«Sturz»:** ein **freies Benutzerattribut** (z. B. „Bauteilrolle")
einmalig per `AddUserAttribute` anlegen bzw. per `GetAttributeID` auffinden und dann pro
Wandsegment setzen. Zusätzlich das native Attribut `Name`/`SetName` der
`WallTierProperties` mit demselben Text belegen, damit es ohne Attributdefinition sichtbar
ist. Die konkrete ID ist projektabhängig → offene Frage O-5.

### Layer

`CommonProperties.Layer : int` (writable), `Color`, `Pen`, `Stroke`;
`CommonProperties.GetGlobalProperties()` übernimmt die aktuellen globalen Einstellungen.
Layer-ID aus Kurzname: `LayerService.GetIDByShortName(shortName: str, doc: DocumentAdapter) -> int`;
`LayerService.GetNameByID(layerID, documentID) -> str`.
Komfort: `ModelEleList.set_layer(layer: int | str, document: DocumentAdapter)`.

---

## G. Brüstung / Sturz – Bewertung und Empfehlung

### Weg 1 – Wandsegmente mit gemischter Höhenanbindung

**Belegt und direkt umsetzbar.** Pro Fenster/Tür entstehen zwei zusätzliche Wandsegmente
mit derselben Achse, derselben Dicke, aber eigenen `PlaneReferences`:

```python
# Brüstung: UK an Geschoss-Unterkante-Ebene, OK auf Absolutkote (= Brüstungshöhe)
pr_bruestung = AllplanArchEle.PlaneReferences(doc, AllplanEleAdapter.BaseElementAdapter())
pr_bruestung.SetBottomPlaneDependency(PlaneReferenceDependency.eBottomPlane)
pr_bruestung.SetBottomOffset(0.0)
pr_bruestung.SetTopPlaneDependency(PlaneReferenceDependency.eAbsElevation)
pr_bruestung.SetTopOffset(bruestung_ok_kote)

# Sturz: UK auf Absolutkote (= Sturz-UK), OK an Geschoss-Oberkante-Ebene
pr_sturz = AllplanArchEle.PlaneReferences(doc, AllplanEleAdapter.BaseElementAdapter())
pr_sturz.SetBottomPlaneDependency(PlaneReferenceDependency.eAbsElevation)
pr_sturz.SetBottomOffset(sturz_uk_kote)
pr_sturz.SetTopPlaneDependency(PlaneReferenceDependency.eTopPlane)
pr_sturz.SetTopOffset(0.0)
```

Beide gehen anschliessend als `WallTierProperties.PlaneReferences` in eine ganz normale
`WallElement`-Erzeugung (A).

* **Pro:** gleicher Objekttyp wie die Regelwand → gleiche Attribute, gleiches Material,
  gleiche Massenermittlung, native Bearbeitbarkeit, automatische Anpassung bei
  Geschosshöhenänderung (die Ebenenanbindung bleibt an einer Kante erhalten).
  Keine zusätzliche Objektfamilie. `StartNewJoinedWallGroup` steuert, ob Segmente
  zusammenwachsen.
* **Contra:** Die Wand wird an jeder Öffnung horizontal geteilt → mehr Objekte; die
  vertikalen Stossfugen zwischen Brüstung/Sturz und Regelwand sind sichtbare
  Bauteilgrenzen. Änderungen an der Öffnungsbreite erfordern das Nachführen mehrerer
  Objekte.

### Weg 2 – Über-/Unterzug (`BeamElement`) oder 3D-Solid

`BeamProperties` (`Bases: ArchBaseProperties`):
`SetAxis(axis: AxisProperties)`, `PlaneReferences`, `ShapeType: ShapeType`, `Width: float`,
`ProfileFullName: str`, `IsStartNewJoinedBeamGroup: bool`;
`BeamElement.__init__(beamProp: BeamProperties, axis: object)`
(`EX/…/ArchitectureExamples/Objects/Beam.py:158–235`).

* **Pro:** ein `BeamElement` mit `PlaneReferences` (unten `eAbsElevation` = Sturz-UK, oben
  `eTopPlane`) ist technisch genauso umsetzbar wie Weg 1. Ein „Sturz" als Unterzug ist
  fachlich für manche Büros die korrekte Darstellung.
* **Contra für unseren Zweck:** Der Auftrag verlangt explizit, dass **die Wand** aufgeteilt
  wird („die Wand wird an der Öffnung in Brüstung und Sturz aufgeteilt"). Ein `BeamElement`
  ist ein anderer Bauteiltyp (andere Attribute, andere Massen-/Bewehrungs-Auswertung,
  andere Priorität beim Bauteilverschnitt). Es entstünde eine Mischung aus Wand- und
  Unterzug-Objekten für dieselbe Wandscheibe.
* **3D-Solid (`ModelElement3D` mit `Polyhedron3D`)** scheidet aus: kein
  Architekturobjekt, keine Ebenenanbindung, keine Rohbau-Attribute, nicht nativ als Wand
  editierbar – widerspricht dem Projektziel „nativ editierbares Rohbaumodell".

### 🟢 Empfohlene Entscheidung (Bestätigung durch Auftraggeber nötig)

> **Weg 1: Wandsegmente mit gemischter Höhenanbindung.**
> Pro Öffnung erzeugt das Werkzeug bis zu drei Wandsegmente auf derselben Achse mit
> derselben `WallProperties`-Vorlage, unterschieden nur durch `PlaneReferences`:
> * **Brüstung** – `BottomPlaneDependency = eBottomPlane`, `BottomOffset = <Geschoss-Offset>`;
>   `TopPlaneDependency = eAbsElevation`, `TopOffset = <Brüstungs-OK-Kote>`
> * **Sturz** – `BottomPlaneDependency = eAbsElevation`, `BottomOffset = <Sturz-UK-Kote>`;
>   `TopPlaneDependency = eTopPlane`, `TopOffset = <Geschoss-Offset>`
> * **Regelwand** links/rechts der Öffnung – beidseitig Ebenenanbindung.
>
> Kennzeichnung über `WallTierProperties.Name` (+ freies Attribut, siehe F).
> `StartNewJoinedWallGroup = True` je Segment, damit Allplan die Segmente nicht
> unkontrolliert zusammenzieht.
>
> **Alternative, falls der Auftraggeber Unterzüge bevorzugt:** Sturz als `BeamElement`
> mit derselben gemischten `PlaneReferences`. Technisch belegt, aber anderer Bauteiltyp.

---

## H. Dämmung und Magerbeton unter der Bodenplatte

**Beides als Decken-/Plattenobjekte mit eigenem Material – kein Sondertyp.** Zwei belegte
Varianten:

1. **Getrennte Objekte (empfohlen):** je eine `SlabElement` (bzw. `SlabFoundationElement`)
   für Magerbeton und Dämmung, jeweils mit
   `props.Material = "Magerbeton"` / `"Dämmung XPS"` und eigener `PlaneReferences`
   (unten/oben typischerweise `eAbsElevation` oder via `SetTopToBottom(bodenplatte_pr)`
   direkt an die UK der Bodenplatte gekoppelt).
   * Vorteil: eigene Attribute, eigene Massen, eigene Layer/Farbe, unabhängig editierbar.
2. **Mehrschichtige Platte:** eine `SlabProperties` mit `TierCount = 3` und
   `GetSlabTierProperties(i).Thickness` + `.Material` je Schicht
   (`SlabTierProperties` erbt `ArchBaseProperties`, hat also `Material`).
   * Vorteil: eine Kontur, eine Höhenanbindung.
   * Nachteil: alle Schichten teilen dieselbe Aussenkontur; Magerbeton ragt in der Praxis
     seitlich über die Bodenplatte hinaus → das geht nur mit Variante 1.

**Es gibt in `NemAll_Python_ArchElements` keine dedizierte Dämmungsklasse** (vollständige
Klassenliste des Moduls abgerufen; enthält keinen Insulation-/Layer-Typ).

---

## I. Bekannte Stolpersteine

**Einheiten**
* Alle Längen und Koordinaten sind **Millimeter**. Manual `features/geometry/#point`
  wörtlich: „The coordinates are always given in millimeters." Gleiches für Vektoren.
* Winkel: `AllplanGeo.Angle` in **Radiant**; `Angle.FromDeg(90)` bzw. `angle.Deg = 90`.
* Attributwerte können in anderen Einheiten geführt sein (z. B. Länge in m):
  `BuildingElementAttributeList.add_attribute_by_unit(id, value)` konvertiert in die
  Attributeinheit – im Zweifel diese Methode nutzen (die Beispiel-Attributliste einer Wand
  zeigt `220 Length = 5.0`, also Meter, bei 5000 mm Geometrie).

**Koordinatensystem**
* Alle Architekturobjekte liegen im **globalen** Koordinatensystem, wenn man
  `CreateElementResult(..., placement_point = Point2D())` setzt – das Wall-Beispiel
  kommentiert das ausdrücklich (`Wall.py:122`: „wall is already in the global coordinate
  system"). Ohne diesen Parameter fordert das Framework einen Platzierungspunkt an und
  verschiebt die Elemente.
* Wandachse: `AxisProperties.Extension = ±1` legt fest, auf welcher Seite der Achse die
  Wand entsteht (+Y bzw. −Y, bezogen auf eine Achse in +X). Default 0 ist ungültig.

**PythonPart-Container vs. native Elemente**
* Ein PythonPart ist ein **Container** (Macro-Placement + Macro-Definition + Views) und
  parametrisch, aber sein Inhalt ist nicht nativ als Wand/Decke editierbar.
* Für unser Ziel gilt: **kein `PythonPartUtil`**, sondern die Architekturobjekte direkt in
  `CreateElementResult(...)` legen (wie `Wall.py`, `Slab.py`, `Column.py`, `Beam.py`,
  `GeneralOpening.py`, `SlabOpening.py` es alle tun).
* `PythonPartUtil.create_pythonpart(build_ele, ...)` nur, wenn man bewusst einen
  parametrischen Container will (z. B. für ein Hilfsobjekt).

**Skript-Kontrakte / `create_element`**
* Standard-PythonPart: `create_element(build_ele: BuildingElement, doc: DocumentAdapter)
  -> CreateElementResult` und `check_allplan_version(build_ele, version: float) -> bool`.
* Script-Object: `create_script_object(build_ele, script_object_data: BaseScriptObjectData)
  -> BaseScriptObject` – die Wand-/Decken-/Öffnungsbeispiele nutzen alle diesen Kontrakt,
  weil sie eine Eingabe (Linie, Polygon, Elementauswahl) brauchen.
* Interactor: `create_interactor(interactor_data: BaseInteractorData) -> Interactor`
  (**neue** 1-Argument-Signatur; die 3- und 7-Argument-Varianten aus älteren Beispielen –
  z. B. `BottomTopPlaneService.py:70–93` – funktionieren noch, sind aber veraltet).
* `CreateElementResult` ist eine Datenklasse mit u. a. `elements: ModelEleList`,
  `handles`, `preview_elements`, `placement_point: Point2D|Point3D|None`,
  `multi_placement: bool`, `elements_to_delete`, `elements_to_hide`, `connect_to_ele`,
  `uuid_parameter_name`.
* Ältere Beispiele geben ein Tupel `(model_ele_list, handle_list)` zurück – laut Manual
  weiterhin gültig, aber nicht empfohlen.

**Tier-Indizes inkonsistent**
* `WallProperties.GetWallTierProperties(tierIndex)` – Doku: „First tier has the index 1!"
* `SlabProperties.GetSlabTierProperties(tierIndex)` – Doku sagt nichts; das offizielle
  Beispiel `Slab.py:181` benutzt `range(TierCount)`, also **0-basiert**.
  → beim Implementieren beide Fälle testen (offene Frage O-6).

**PlaneReferences im PythonPart = Update-Risiko**
* Manual `key_components/palette/parameter_with_dialog/#plane-references` (Warnung,
  wörtlich): Wenn Ebenen im Höhenmanager geändert werden, prüft und aktualisiert Allplan
  **alle** PythonParts mit einem `PlaneReferences`-Parameter. „To prevent ALLPLAN getting
  stuck during this process, make sure, that reactivating your PythonPart with double-click
  and hitting Esc directly afterwards leads to a clean script termination."
  → Betrifft uns nur, falls wir doch PythonPart-Container erzeugen; bei nativen
  Architekturobjekten entfällt es.

**Versionsunterschiede**
* `SlabFoundationElement` (Fundamentplatte) ist **neu in 2026** (Release Notes „WIP-3").
  → in 2025 nicht verfügbar.
* `MoveElementsToDrawingFile` / `CopyElementsToDrawingFile`, `DrawingFileService`-Erweiterung
  (Namen lesen/ändern), `ValueType` `DrawingFile`, `HandleCreator`,
  `ElementsAttributeService`-Löschen/Undef: alle **neu in 2026**.
* Modifikation bestehender `WallElement`, `ColumnElement`, `BeamElement`,
  `GeneralOpeningElement`, `DoorOpeningElement`, `WindowOpeningElement`: neu ab
  2026-WIP-1/2.
* Python-Interpreter in Allplan 2026: **3.13.9** (Release Notes 2026-0-3).
  In 2026-WIP-4 war es 3.13.2.
* PYP-Schema: `xsi:noNamespaceSchemaLocation="https://pythonparts.allplan.com/2026/schemas/PythonPart.xsd"`.
  Ab 2026-WIP-4 werden alle `<Parameter>` in einen `<Parameters>`-Container gruppiert
  (alte Struktur funktioniert noch).
* Für 2027 liegen **keine** Informationen vor (Doku-Site wurde nur für 2026 abgefragt).

**Sonstiges**
* Öffnungen brauchen ein existierendes Elternbauteil (siehe D) → Zwei-Pass.
* `ModifyElements(doc, modelEleList)` ist langsam; Manual empfiehlt ausdrücklich, Änderungen
  zu sammeln und **einmal** am Ende zu schreiben.
* `ShapeGeometryPropertiesParameterUtil`, `VerticalOpeningGeometryPropertiesParameterUtil`,
  `OpeningSillPropertiesParameterUtil`, `OpeningSymbolsPropertiesParameterUtil` und die
  `.incl`-Dateien unter `etc\PythonPartsFramework\ParameterIncludes\` sind **nicht** im
  Beispiel-Repo enthalten – nur in der Allplan-Installation. Unser Adapter sollte sie
  meiden und die Properties direkt setzen.

---

## J. Dateiablage (für das Sync-Skript)

Manual `key_components/#file-locations` (wörtlich, inkl. Warnung):

```
📁 std\   OR   usr\<USER_NAME>\   OR   prj\<PROJECT_NAME>\
├── 📁 Library\
│   └── 📁 MyPythonParts\
│       ├── 📄 MyPythonPart.pyp        ← macht den PythonPart in der Allplan-Bibliothek sichtbar
│       ├── 🖼️ MyPythonPart.png        ← Thumbnail, gleicher Ordner wie .pyp
│       └── 📄 MyPythonPart_deu.xml    ← String-Ressourcen (Lokalisierung)
└── 📁 PythonPartsScripts\
    └── 📁 MyPythonParts\
        └── 📄 MyPythonPart.py
```

* Der `<Script><Name>`-Eintrag im `.pyp` ist der Pfad der `.py` **relativ zu
  `PythonPartsScripts`** (Backslashes), z. B. `<Name>MyPythonParts\MyPythonPart.py</Name>`.
  Beispiel: `EX/Library/Examples/PythonParts/ArchitectureExamples/Objects/Wall.pyp:4`
  → `ArchitectureExamples\Objects\Wall.py`.
* Sichtbarkeit: `std\` = ganzes Büro, `usr\<name>\` = ein Benutzer,
  `prj\<projekt>\` = ein Projekt (Manual: „not recommended").
* **`etc\` niemals beschreiben** – Manual-Warnung wörtlich: „Do not use the `...\etc\`
  directory to store any of your files as it is the property of ALLPLAN and its content
  can be deleted or moved during an update!"
* Such-Reihenfolge des Python-Imports für `PythonPartsScripts`:
  `prj\<Projekt>\PythonPartsScripts` → `std\PythonPartsScripts` →
  `usr\<User>\PythonPartsScripts` → `etc\PythonPartsScripts` (Manual
  `getting_started/#python-environment`; das Manual nennt die Liste ausdrücklich als
  „may not be exhaustive", die Reihenfolge prj → std → usr steht in
  `key_components/#file-structure`).
* Site-Packages (falls wir z. B. `shapely` brauchen):
  `std\PythonParts-site-packages`, `usr\<User>\PythonParts-site-packages`,
  `etc\PythonParts-site-packages`; Ladereihenfolge std → usr → etc.
  Installation über das SDK-Werkzeug „Install Python Package".
* Ein Plugin-Paket (`.allep`) ist ein ZIP aus `Library/`, `PythonPartsScripts/` und
  `install-config.yml` (Manual `for_developer/delivery`; identische Struktur im
  SDK-Klon `.../pythonparts-sdk`: `Library/`, `PythonPartsScripts/`,
  `PythonPartsActionbar/`, `install-config.yml`).

**Konkret für das Sync-Skript:** zwei parallele Bäume spiegeln, mit gleicher
Unterordnerstruktur, Ziel z. B.

```
<Allplan-Std-Pfad>\Library\Plan2Allplan\*.pyp  (+ .png, + _deu.xml)
<Allplan-Std-Pfad>\PythonPartsScripts\Plan2Allplan\*.py
```

Der Std-Pfad ist zur Laufzeit über `AllplanSettings.AllplanPaths` ermittelbar
(im Beispiel `AllplanSettings.AllplanPaths.GetPythonPartsEtcPath()` verwendet,
`Wall`-/`Column`-Preview). Andere `AllplanPaths`-Getter wurden **nicht** gelesen →
offene Frage O-7.

---

## Offene Fragen an den Auftraggeber

**O-1 – Semantik der Plane-Dependencies.** Die Referenz nennt nur die Enum-Namen
`eAbsElevation, eBottomPlane, eTopPlane, eComponentsBottomPlane, eComponentsTopPlane,
eTopFixed, eBottomFixed` ohne Beschreibung. Ich empfehle `eBottomPlane`/`eTopPlane` für die
Standard-Ebenen und `eAbsElevation` für Absolutkoten. Bitte am Windows-Rechner mit
installierten Stubs prüfen (die `.pyi` unter
`...\Prg\PythonPartsFramework\` enthalten evtl. Kommentare) bzw. an einer Testwand
verifizieren, ob `eBottomPlane` tatsächlich „untere Standardebene des Teilbilds" bedeutet.

**O-2 – Ebenen anderer Geschosse referenzieren.** `ReferencePlaneID(modelGuid, planeId)`
existiert, aber es ist nicht dokumentiert, woher `ModelGuid`/`PlaneId` kommen. Soll das
Werkzeug ausschliesslich die Standard-Ebenen des jeweils aktiven Teilbilds nutzen
(`IsDefaultLowerPlane`/`IsDefaultUpperPlane`), oder brauchen wir geschossübergreifende
Ebenenreferenzen? Falls Letzteres: bitte einen Anwendungsfall benennen, damit ich gezielt
nachrecherchieren kann.

**O-3 – Durchgehende Wandöffnung.** Ist `GeneralOpeningProperties.OpeningType = eRecess`
mit `GetGeometryProperties().Depth = 0` die korrekte Kodierung für „durchgehend",
oder muss `Depth` explizit auf die Wanddicke gesetzt werden? Am Testmodell prüfen.

**O-4 – Teilbildwechsel zur Laufzeit.** Darf das Werkzeug während eines Laufs mit
`DrawingFileService.LoadFile(..., ActiveForeground)` das aktive Teilbild wechseln, oder
soll pro Geschoss ein separater Lauf gestartet werden (Benutzer setzt das Teilbild vorher
selbst aktiv)? Letzteres ist deutlich risikoärmer.

**O-5 – Attribut für «Brüstung»/«Sturz».** Gibt es im Büro-Standard bereits ein passendes
(Benutzer-)Attribut samt Nummer? Sonst: soll das Werkzeug beim ersten Lauf per
`AttributeService.AddUserAttribute` eines anlegen – und unter welchem Namen?

**O-6 – Slab-Tier-Index.** 0- oder 1-basiert? Am Testmodell verifizieren (Wand ist
dokumentiert 1-basiert, Decke im Beispiel 0-basiert).

**O-7 – Zielpfade des Sync-Skripts.** Welcher Ablageort ist gewünscht: `std\` (büroweit)
oder `usr\<Benutzer>\` (nur Auftraggeber)? Und wie lautet der konkrete Allplan-Std-Pfad auf
dem Zielrechner (z. B. `C:\Data\Allplan\2026\Std\`)?

**O-8 – Bauwerksstruktur.** Da die Geschossliste nicht per API lesbar ist: soll die
Zuordnung „Geschoss → Teilbildnummer + Ebenen-Offsets" in einer Projektkonfiguration
(JSON/YAML) gepflegt werden, die der Auftraggeber einmalig befüllt? Das ist der einzige
belegbare Weg.

**O-9 – Liftgrube.** Wie soll die Liftgrube modelliert werden: (a) tieferliegende
`SlabFoundationElement` + umlaufende Wände mit eigener `PlaneReferences`, oder (b) als
Rücksprung (`SlabOpeningType.eRecess`) in der Bodenplatte? Beide Wege sind API-seitig
belegt; (a) ist für Rohbau-Massen sauberer.

**O-10 – Material-Schreibweise.** `ArchBaseProperties.Material` ist ein **freier String**.
Welche Werteliste soll das Werkzeug schreiben (z. B. „C25/30", „Beton C25/30", ein
Katalogschlüssel)?

---

## Empfohlene Entscheidung Brüstung/Sturz (zur Bestätigung)

**Weg 1 – Wandsegmente mit gemischter Höhenanbindung über `PlaneReferences`.**

Begründung in einem Satz: Die API stützt Bottom- und Top-Anbindung vollständig unabhängig
(`BottomPlaneDependency`/`TopPlaneDependency` + `BottomOffset`/`TopOffset`, wobei der Offset
bei `eAbsElevation` die Absolutkote *ist*), damit ist die geforderte Mischform ohne
Hilfskonstruktion abbildbar – und das Ergebnis bleibt ein gewöhnliches, nativ editierbares
Wandbauteil mit denselben Attributen und derselben Massenermittlung wie die Regelwand.

Fallback, falls der Auftraggeber Unterzüge will: `BeamElement` mit identischer
`PlaneReferences`-Logik – ebenfalls vollständig belegt, aber anderer Bauteiltyp.
Ausgeschlossen: 3D-Solid (`ModelElement3D`), weil damit die Anforderung
„nativ editierbares Rohbaumodell" verfehlt würde.
