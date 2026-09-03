# API-Quellenprotokoll (api_evidence.md)

Jedes API-Symbol, das in `core/` oder `allplan_adapter/` verwendet wird, muss hier stehen.
Format: Symbol · Quelle (URL / Dateipfad:Zeile) · gefundene Signatur · Datum.
Der Reviewer lehnt jeden Aufruf ab, der hier fehlt.

Abkürzung für lokale Klone in dieser Session:
- `EX/` = https://github.com/NemetschekAllplan/PythonPartsExamples, Branch `2026`
  (lokal: `/tmp/.../scratchpad/PythonPartsExamples/`)
- `DOC/` = https://pythonparts.allplan.com/2026/

## Etappe 0 – Dummy-PythonPart (allplan_adapter/PythonPartsScripts/Plan2Allplan/dummy.py)

| Symbol | Quelle | gefundene Signatur | Datum |
|---|---|---|---|
| `check_allplan_version(build_ele, version)` | EX/PythonPartsExampleScripts/ToolsAndStartExamples/HelloWorld.py:18 | `def check_allplan_version(_build_ele: BuildingElement, _version: str)` → bool | 2026-09-03 |
| `create_element(build_ele, doc)` | EX/PythonPartsExampleScripts/ToolsAndStartExamples/HelloWorld.py:35 | `def create_element(build_ele: BuildingElement, _doc: AllplanElementAdapter.DocumentAdapter)` → `(model_elem_list, handle_list)` | 2026-09-03 |
| `BuildingElement` | EX/PythonPartsExampleScripts/ToolsAndStartExamples/HelloWorld.py:11 | `from BuildingElement import BuildingElement`; Parameterzugriff `build_ele.Length.value` | 2026-09-03 |
| `NemAll_Python_Geometry.Line2D` | EX/…/HelloWorld.py:55 | `AllplanGeo.Line2D(0, 0, length, 0)` | 2026-09-03 |
| `NemAll_Python_AllplanSettings.AllplanGlobalSettings.GetCurrentCommonProperties` | EX/…/HelloWorld.py:60 | `AllplanSettings.AllplanGlobalSettings.GetCurrentCommonProperties()` | 2026-09-03 |
| `NemAll_Python_BasisElements.ModelElement2D` | EX/…/HelloWorld.py:65 | `AllplanBasisElements.ModelElement2D(common_props, line)` | 2026-09-03 |
| `NemAll_Python_IFW_ElementAdapter.DocumentAdapter` | EX/…/HelloWorld.py:36 | Typ des `doc`-Arguments von `create_element` | 2026-09-03 |
| `.pyp`-Struktur (`<Script><Name>`, `<Page>`, `<Parameter>` mit `ValueType` Length) | EX/Library/Examples/PythonParts/ToolsAndStartExamples/HelloWorld.pyp | XML nach `https://pythonparts.allplan.com/2026/schemas/PythonPart.xsd` | 2026-09-03 |
| Skript-Ablage (`<Script><Name>` = Pfad relativ zu `PythonPartsScripts`, Backslash) | EX/Library/Examples/PythonParts/ToolsAndStartExamples/HelloWorld.pyp:4 (`ToolsAndStartExamples\HelloWorld.py`); DOC/manual/key_components/ (File locations, siehe docs/research_allplan.md Abschnitt J) | `.pyp` `<Name>Plan2Allplan\dummy.py</Name>` → `PythonPartsScripts/Plan2Allplan/dummy.py`; `__init__.py` leer wie in den offiziellen Beispielen | 2026-09-03 |

## Etappe 0 – Recherche-Belege

Zusammengeführt aus den drei Research-Berichten (Originaldateien: docs/evidence_allplan.md, docs/evidence_ifc.md, docs/evidence_extraction.md; die Datei hier ist die verbindliche Gesamtliste).

### Allplan 2026 PythonParts API

## Allplan-Quellenprotokoll (evidence_allplan.md)

Recherche-Agent `research-allplan`. Allplan-Version **2026**. Datum aller Einträge: **2026-09-03**.

Alle unten aufgeführten Symbole wurden in dieser Session tatsächlich gelesen – entweder auf der
angegebenen Doku-Seite oder in der angegebenen Beispieldatei (Zeilennummer). Nichts ist geraten.

**Abkürzungen für die Quellenspalte**

* `API/<Modul>/<Klasse>` = `https://pythonparts.allplan.com/2026/api_reference/InterfaceStubs/<Modul>/<Klasse>/`
* `GS/<Name>` = `https://pythonparts.allplan.com/2026/api_reference/GeneralScripts/<Name>/`
* `TC/<Name>` = `https://pythonparts.allplan.com/2026/api_reference/TypeCollections/<Name>/`
* `MAN/<pfad>` = `https://pythonparts.allplan.com/2026/manual/<pfad>`
* `EX/…` = lokaler Klon der offiziellen Beispiele, Branch `2026`, HEAD `e816b12`:
  `/tmp/claude-0/-home-user-plan2allplan/cec3c10c-725f-583f-94fd-2cc650e8bb6c/scratchpad/PythonPartsExamples/…`
* Modulkürzel: `ArchEle` = `NemAll_Python_ArchElements`, `BaseEle` = `NemAll_Python_BaseElements`,
  `BasisEle` = `NemAll_Python_BasisElements`, `Geo` = `NemAll_Python_Geometry`,
  `EleAdapter` = `NemAll_Python_IFW_ElementAdapter`, `IFW` = `NemAll_Python_IFW_Input`,
  `Settings` = `NemAll_Python_AllplanSettings`

| Symbol | Quelle (URL oder Dateipfad:Zeile) | gefundene Signatur | Datum |
|---|---|---|---|
| **A – Wand** ||||
| `ArchEle.WallProperties` | API/NemAll_Python_ArchElements/WallProperties | `__init__()` · `__init__(wallProp: WallProperties)` — „Representation of properties of a multi layer wall" | 2026-09-03 |
| `WallProperties.Axis` | API/…/WallProperties | `Axis : AxisProperties` (property, writable) | 2026-09-03 |
| `WallProperties.TierCount` | API/…/WallProperties | `TierCount : int` (writable); `GetTierCount() -> int`; `SetTierCount(tierCount: int)` | 2026-09-03 |
| `WallProperties.StartNewJoinedWallGroup` | API/…/WallProperties | `StartNewJoinedWallGroup : bool` (writable) — „All walls in a group are used for to create a continues join between the walls." | 2026-09-03 |
| `WallProperties.GetWallTierProperties` | API/…/WallProperties | `GetWallTierProperties(tierIndex: int) -> WallTierProperties` — „Tier index. **First tier has the index 1!**" | 2026-09-03 |
| `WallProperties.GetThickness` | API/…/WallProperties | `GetThickness() -> float` | 2026-09-03 |
| `WallProperties.SetAxis` | API/…/WallProperties | `SetAxis(axis: AxisProperties)` | 2026-09-03 |
| `WallProperties.LoadFromFavoriteFile` | API/…/WallProperties | `LoadFromFavoriteFile(doc: DocumentAdapter)` | 2026-09-03 |
| `ArchEle.WallTierProperties` | API/NemAll_Python_ArchElements/WallTierProperties | `Bases: ArchBaseProperties`; `Thickness : float` (writable); `GetThickness() -> float`; `SetThickness(thickness: float)`; `__init__(tierProp: WallTierProperties)` | 2026-09-03 |
| `ArchEle.WallElement` | API/NemAll_Python_ArchElements/WallElement | `Bases: ArchElement, AllplanElement`; `__init__()` · `__init__(wallProp: WallProperties, axis: object)` · `__init__(element: WallElement)`; `SetProperties(wallProp: WallProperties)`; `SetCommonProperties(commonProp: CommonProperties)` | 2026-09-03 |
| Wand-Achsengeometrie | MAN/features/allplan_elements/#primary-components | Tabelle: „Wall → `WallElement` → Geometry: `Line2D`, `Arc2D` or any 2D curve" | 2026-09-03 |
| `ArchEle.AxisProperties` | API/NemAll_Python_ArchElements/AxisProperties | `__init__()`; `Distance: float`, `Extension: int`, `Modus: int`, `OnTier: int`, `Position: int` (alle writable) | 2026-09-03 |
| `AxisProperties.Extension` | API/…/AxisProperties | „1 → component above the axis (+Y); -1 → below (-Y). **IMPORTANT: Default value is 0 and must be changed to either 1 or -1!**" | 2026-09-03 |
| `AxisProperties.Distance` | API/…/AxisProperties | „**IMPORTANT**: The value must be set in the range between `<0.0, component_width>`" | 2026-09-03 |
| `ArchEle.WallAxisPosition` | API/NemAll_Python_ArchElements/WallAxisPosition | `Bases: Enum`; `eLeft = 1`, `eCenter = 2`, `eRight = 4`, `eFree = 8`, `eUnknown` | 2026-09-03 |
| Wand-Erzeugung (Beispiel) | EX/PythonPartsExampleScripts/ArchitectureExamples/Objects/Wall.py:158-197 | `wall_prop = AllplanArchElements.WallProperties()` … `wall_tier_prop = wall_prop.GetWallTierProperties(tier_index + 1)` · `wall_tier_prop.PlaneReferences = …` · `wall_tier_prop.Thickness = …` | 2026-09-03 |
| Wand-Element (Beispiel) | EX/…/Objects/Wall.py:238-248 | `return AllplanArchElements.WallElement(self.wall_properties, axis)` mit `axis: AllplanGeometry.Line2D` | 2026-09-03 |
| Native Rückgabe ohne PythonPart | EX/…/Objects/Wall.py:119-122 | `return CreateElementResult([self.wall_element(axis)], placement_point = AllplanGeometry.Point2D())  # wall is already in the global coordinate system` | 2026-09-03 |
| `.pyp`-Parameter `PlaneReferences` | EX/Library/Examples/PythonParts/ArchitectureExamples/Objects/Wall.pyp:136-144 | `<ValueType>PlaneReferences</ValueType><ValueDialog>PlaneReferences</ValueDialog><Dimensions>TierCount</Dimensions>` | 2026-09-03 |
| **Höhen / Ebenen** ||||
| `ArchEle.PlaneReferences` | API/NemAll_Python_ArchElements/PlaneReferences | `__init__(doc: DocumentAdapter, refElement: BaseElementAdapter)` · `__init__(element: PlaneReferences)` (Copy) | 2026-09-03 |
| `PlaneReferences.PlaneReferenceDependency` | API/…/PlaneReferences | `Bases: Enum` — „Definition of the plane dependencies": `eAbsElevation`, `eBottomPlane`, `eTopPlane`, `eComponentsBottomPlane`, `eComponentsTopPlane`, `eTopFixed`, `eBottomFixed`; `__getitem__(key: str\|int\|float) -> PlaneReferenceDependency` | 2026-09-03 |
| `PlaneReferences.Direction` | API/…/PlaneReferences | `Bases: Enum`: `eParallel`, `eOrthogonal` | 2026-09-03 |
| `PlaneReferences.ElementToPlaneModeling` | API/…/PlaneReferences | `Bases: Enum`: `eFitToPlane`, `eLowerCutToPlane`, `eUpperCutToPlane` | 2026-09-03 |
| `PlaneReferences.BottomOffset` | API/…/PlaneReferences | `BottomOffset : float` (writable) — „Offset between the reference plane and the bottom edge of an architectural component. **If the property `BottomPlaneDependency` is set to `eAbsElevation`, this is the absolute elevation of the bottom edge.**" | 2026-09-03 |
| `PlaneReferences.TopOffset` | API/…/PlaneReferences | `TopOffset : float` (writable) — „…If the property `TopPlaneDependency` is set to `eAbsElevation`, this is the absolute elevation of the top edge." | 2026-09-03 |
| `PlaneReferences.BottomPlaneDependency` | API/…/PlaneReferences | `BottomPlaneDependency : PlaneReferenceDependency` (writable) — „Type of dependency of the bottom edge of the architectural component" | 2026-09-03 |
| `PlaneReferences.TopPlaneDependency` | API/…/PlaneReferences | `TopPlaneDependency : PlaneReferenceDependency` (writable) | 2026-09-03 |
| `PlaneReferences.SetBottomPlaneDependency` | API/…/PlaneReferences | `SetBottomPlaneDependency(dependency: PlaneReferenceDependency)` | 2026-09-03 |
| `PlaneReferences.SetTopPlaneDependency` | API/…/PlaneReferences | `SetTopPlaneDependency(dependency: PlaneReferenceDependency)` | 2026-09-03 |
| `PlaneReferences.SetBottomOffset` / `GetBottomOffset` | API/…/PlaneReferences | `SetBottomOffset(offset: float)` · `GetBottomOffset() -> float` | 2026-09-03 |
| `PlaneReferences.SetTopOffset` / `GetTopOffset` | API/…/PlaneReferences | `SetTopOffset(offset: float)` · `GetTopOffset() -> float` | 2026-09-03 |
| `PlaneReferences.SetBottomElevation` / `GetBottomElevation` | API/…/PlaneReferences | `SetBottomElevation(elevation: float)` · `GetBottomElevation() -> float` — „relative to the bottom plane of the document" | 2026-09-03 |
| `PlaneReferences.SetTopElevation` / `GetTopElevation` | API/…/PlaneReferences | `SetTopElevation(elevation: float)` · `GetTopElevation() -> float` | 2026-09-03 |
| `PlaneReferences.SetAbsBottomElevation` / `GetAbsBottomElevation` | API/…/PlaneReferences | `SetAbsBottomElevation(absElevation: float)` · `GetAbsBottomElevation() -> float` | 2026-09-03 |
| `PlaneReferences.SetAbsTopElevation` / `GetAbsTopElevation` | API/…/PlaneReferences | `SetAbsTopElevation(absElevation: float)` · `GetAbsTopElevation() -> float` | 2026-09-03 |
| `PlaneReferences.SetBottomReferencePlane` / `GetBottomReferencePlane` | API/…/PlaneReferences | `SetBottomReferencePlane(bottomReferencePlane: ReferencePlaneID)` · `GetBottomReferencePlane() -> ReferencePlaneID` | 2026-09-03 |
| `PlaneReferences.SetTopReferencePlane` / `GetTopReferencePlane` | API/…/PlaneReferences | `SetTopReferencePlane(topReferencePlane: ReferencePlaneID)` · `GetTopReferencePlane() -> ReferencePlaneID` | 2026-09-03 |
| `PlaneReferences.SetBottomToBottom` / `SetBottomToTop` | API/…/PlaneReferences | `SetBottomToBottom(planeRef: PlaneReferences)` · `SetBottomToTop(planeRef: PlaneReferences)` — „Set the bottom level to the bottom/top level of the source plane reference" | 2026-09-03 |
| `PlaneReferences.SetTopToBottom` / `SetTopToTop` | API/…/PlaneReferences | `SetTopToBottom(planeRef: PlaneReferences)` · `SetTopToTop(planeRef: PlaneReferences)` | 2026-09-03 |
| `PlaneReferences.SetHeight` / `GetHeight` | API/…/PlaneReferences | `SetHeight(height: float)` · `GetHeight() -> float`; ebenso `SetMaximumHeight/GetMaximumHeight` | 2026-09-03 |
| `PlaneReferences.SetDocument` / `GetDocument` | API/…/PlaneReferences | `SetDocument(doc: DocumentAdapter)` · `GetDocument() -> DocumentAdapter` | 2026-09-03 |
| `PlaneReferences.SetReferenceElement` / `GetReferenceElement` | API/…/PlaneReferences | `SetReferenceElement(refElement: BaseElementAdapter)` · `GetReferenceElement() -> BaseElementAdapter` | 2026-09-03 |
| `PlaneReferences.SetBottomPlaneSurface` / `SetTopPlaneSurface` | API/…/PlaneReferences | `SetBottomPlaneSurface(bottomSurface: object)` · `SetTopPlaneSurface(topPlaneSurface: object)`; Getter `-> Any` | 2026-09-03 |
| `PlaneReferences.SetBottomSurfacePlaneElement` / `SetTopSurfacePlaneElement` | API/…/PlaneReferences | `SetBottomSurfacePlaneElement(surfacePlane: BaseElementAdapter)` · `SetTopSurfacePlaneElement(surfacePlane: BaseElementAdapter)` | 2026-09-03 |
| `PlaneReferences.SetBottomDirection` / `SetTopDirection` | API/…/PlaneReferences | `SetBottomDirection(direction: Direction)` · `SetTopDirection(direction: Direction)` | 2026-09-03 |
| `PlaneReferences.SetElementToPlaneModeling` | API/…/PlaneReferences | `SetElementToPlaneModeling(elementToPlaneModeling: ElementToPlaneModeling)` | 2026-09-03 |
| Default-Ebenen des Teilbilds (Beispiel) | EX/…/Objects/SlabOpening.py:117 · EX/…/Objects/GeneralOpeningsFor3DSolids.py:318 | `AllplanArchEle.PlaneReferences(self.document, AllplanEleAdapter.BaseElementAdapter())` | 2026-09-03 |
| Copy-Ctor (Beispiel) | EX/…/Objects/SlabOpening.py:159 | `AllplanArchEle.PlaneReferences(self.slab_plane_ref)` | 2026-09-03 |
| `ArchEle.ReferencePlaneID` | API/NemAll_Python_ArchElements/ReferencePlaneID | „struct for handling reference plane IDs"; `__init__()` · `__init__(modelGuid: GUID, planeId: int)` · `__init__(element: ReferencePlaneID)`; `ModelGuid: GUID` (writable), `PlaneId: int` (read-only) | 2026-09-03 |
| `ReferencePlaneID.IsDefaultLowerPlane` | API/…/ReferencePlaneID | `IsDefaultLowerPlane() -> bool` — „Find out if reference plane is default lower reference plane" | 2026-09-03 |
| `ReferencePlaneID.IsDefaultUpperPlane` | API/…/ReferencePlaneID | `IsDefaultUpperPlane() -> bool` | 2026-09-03 |
| `ReferencePlaneID.IsDocumentRefSurface` | API/…/ReferencePlaneID | `IsDocumentRefSurface() -> bool` — „true is reference surface from document (not in model)" | 2026-09-03 |
| `ReferencePlaneID.IsInModel` / `IsValid` / `Invalidate` | API/…/ReferencePlaneID | `IsInModel() -> bool` · `IsValid() -> bool` · `Invalidate()` | 2026-09-03 |
| `ReferencePlaneID.SetCustomLowerPlane` / `SetCustomUpperPlane` | API/…/ReferencePlaneID | `SetCustomLowerPlane()` · `SetCustomUpperPlane()` | 2026-09-03 |
| `ArchEle.BottomTopPlaneService.GetAbsoluteBottomElevation` | API/NemAll_Python_ArchElements/BottomTopPlaneService | `(refElement: BaseElementAdapter, doc: DocumentAdapter, planeProp: BasePlaneReferences) -> float` | 2026-09-03 |
| `BottomTopPlaneService.GetAbsoluteTopElevation` | API/…/BottomTopPlaneService | `(refElement, doc, planeProp) -> float` | 2026-09-03 |
| `BottomTopPlaneService.GetDocumentBottomElevation` / `GetDocumentTopElevation` | API/…/BottomTopPlaneService | `(refElement, doc, planeProp) -> float` | 2026-09-03 |
| `BottomTopPlaneService.GetBottomReferencePlane` / `GetTopReferencePlane` | API/…/BottomTopPlaneService | `(refElement, doc, planeProp) -> BRep3D \| Polyhedron3D \| Plane3D` | 2026-09-03 |
| `BottomTopPlaneService.GetDocumentDefaultPlanes` | API/…/BottomTopPlaneService | `(doc: DocumentAdapter) -> tuple[Plane3D, Plane3D]` | 2026-09-03 |
| Nutzung BottomTopPlaneService (Beispiel) | EX/PythonPartsExampleScripts/ServiceExamples/BottomTopPlaneService.py:275-293, 415-424 | `plane_refs.GetAbsBottomElevation()`; `AllplanArchEle.BottomTopPlaneService.GetAbsoluteBottomElevation(AllplanEleAdapter.BaseElementAdapter(), doc, plane_refs)`; `…GetDocumentDefaultPlanes(doc)`; `…GetBottomReferencePlane(…)` | 2026-09-03 |
| Nutzung (Beispiel 2) | EX/PythonPartsExampleScripts/BasisExamples/General/PlaneConnection.py:130-131, 162-165 | `plane_ref.GetAbsBottomElevation()` · `plane_ref.GetAbsTopElevation()` · `AllplanArchElements.BottomTopPlaneService.GetAbsoluteBottomElevation(…)` | 2026-09-03 |
| Ebenen-Konzept (Manual) | MAN/features/connections/#plane-connection | „Planes in ALLPLAN can represent e.g. the top or bottom of a floor in a building. … A reference to a plane is represented by a `PlaneReferences` object." | 2026-09-03 |
| `PlaneReferences`-Dialogtypen im `.pyp` | MAN/key_components/palette/parameter_with_dialog/#plane-references | `<ValueDialog>` ∈ {`PlaneReferences`, `BottomPlaneReferences`, `TopPlaneReferences`}; „the object `PlaneReferences` holds information about references to both top and bottom level" | 2026-09-03 |
| `<Constraint>`-Schlüsselwörter | MAN/key_components/palette/parameter_with_dialog/#constraints | `AbsBottomElevation`, `BottomElevation`, `AbsTopElevation`, `TopElevation`, `Height` (Recalculation-Tabelle) | 2026-09-03 |
| **B – Stütze** ||||
| `ArchEle.ColumnProperties` | API/NemAll_Python_ArchElements/ColumnProperties | `Bases: VerticalElementProperties, ArchBaseProperties` | 2026-09-03 |
| `ArchEle.ColumnElement` | API/NemAll_Python_ArchElements/ColumnElement | `Bases: ArchElement, AllplanElement`; `__init__()` · `__init__(columnProp: ColumnProperties, placementPoint: object)` · `__init__(element: ColumnElement)`; `PlacementPoint : Point2D` (writable); `SetProperties(ColumnProp)`; `SetCommonProperties(commonProp: CommonProperties)` | 2026-09-03 |
| `ArchEle.VerticalElementProperties` | API/NemAll_Python_ArchElements/VerticalElementProperties | `Bases: ArchBaseProperties`; Properties `Angle: Angle`, `Depth: float`, `Radius: float`, `Width: float`, `ShapeType: ShapeType`, `ShapePolygon: Polygon2D`, `ProfileFullName: str`; Methoden `SetAngle`, `SetDepth`, `SetRadius`, `SetWidth`, `SetSize`, `SetCornerRadius`, `SetShapeType`, `SetShapePolygon`, `SetProfileFullName`, `SetAttribute` | 2026-09-03 |
| `ArchEle.ShapeType` | API/NemAll_Python_ArchElements/ShapeType | `Bases: Enum`; `eRectangular` („Rectangular cross section"), `eCircular` („Round cross section"), `ePolygonal` („bounded with a free, closed polygon"), `eProfile`, `eArbitrary = 6`, `eChamfer`, `eConical`, `eRegularPolygonInscribed`, `eRegularPolygonCircumscribed`, `eRiseBottomTop`, `eStep`, `eUnknown` | 2026-09-03 |
| Stütze (Beispiel) | EX/PythonPartsExampleScripts/ArchitectureExamples/Objects/Column.py:169-173, 214-216 | `column_prop = AllplanArchEle.ColumnProperties()` · `column_prop.PlaneReferences = …` · `AllplanArchEle.ColumnElement(self.create_column_properties(), input_point)` | 2026-09-03 |
| `ArchEle.StructuralColumnProperties` (Alternative) | EX/PythonPartsExampleScripts/StructuralFramingExamples/StructuralColumn.py:54-116 | `StructuralColumnProperties()`; `SetProfileShapeProperties(shape)`; `SetProfileAngle(angle: Angle)`; `SetCommonProperties(cp)`; `SetMaterial(str)`; `SetPosition(x, y, z)`; `SetHeightProperties(doc, planeReferences)`; `SetAnchorPointProperties(anchor: int, offset)`; `SetAnglesAtStart(ax, ay)`; `SetAnglesAtEnd(ax, ay)` | 2026-09-03 |
| `ArchEle.StructuralColumnElement` | EX/…/StructuralFramingExamples/StructuralColumn.py:115-116 | `StructuralColumnElement(columnProps)`; `column.SetAxisVisibility(bool)` | 2026-09-03 |
| `ArchEle.RectangularShape` / `CircularShape` / `ProfileShape` | EX/…/StructuralFramingExamples/StructuralColumn.py:57-76 | `RectangularShape().Width`, `.Thickness`; `CircularShape().Radius`; `ProfileShape().ProfilePath` | 2026-09-03 |
| **C – Decke / Bodenplatte** ||||
| `ArchEle.SlabProperties` | API/NemAll_Python_ArchElements/SlabProperties | `Bases: ArchBaseProperties`; `TierCount : int` (writable), `VariableTier : int` (writable), `SetTierCount`, `SetVariableTier`, `GetPresentationProperties`, `SetAttribute` | 2026-09-03 |
| `SlabProperties.GetSlabTierProperties` | API/…/SlabProperties | `GetSlabTierProperties(tierIndex: int) -> SlabTierProperties` (Doku macht **keine** Angabe zur Indexbasis) | 2026-09-03 |
| `ArchEle.SlabTierProperties` | API/NemAll_Python_ArchElements/SlabTierProperties | `Bases: ArchBaseProperties`; `Thickness : float` (writable); `GetThickness() -> float`; `SetThickness(thickness: float)` | 2026-09-03 |
| `ArchEle.SlabElement` | API/NemAll_Python_ArchElements/SlabElement | `Bases: ArchElement, AllplanElement`; `__init__()` · `__init__(slabProp: SlabProperties, slabPolygon: Polygon2D)` · `__init__(element: SlabElement)`; `Properties : SlabProperties` (writable); `GetProperties()`; `SetProperties(SlabProp)` — **nur `Polygon2D`, keine Löcher** | 2026-09-03 |
| `ArchEle.SlabFoundationProperties` | API/NemAll_Python_ArchElements/SlabFoundationProperties | `Bases: SlabProperties, ArchBaseProperties` | 2026-09-03 |
| `ArchEle.SlabFoundationElement` | API/NemAll_Python_ArchElements/SlabFoundationElement | `Bases: SlabElement, ArchElement, AllplanElement`; `__init__()` · `__init__(slabFoundProp: SlabFoundationProperties, slabPolygon: Polygon2D)` · `__init__(element: SlabFoundationElement)` | 2026-09-03 |
| Decke (Beispiel) | EX/PythonPartsExampleScripts/ArchitectureExamples/Objects/Slab.py:169-195, 211 | `slab_prop = AllplanArchElements.SlabProperties()` · `slab_prop.PlaneReferences = …` · `slab_prop.TierCount = …` · `slab_prop.VariableTier = …` · `slab_prop.GetSlabTierProperties(tier_index)` mit `tier_index in range(TierCount)` (0-basiert) · `AllplanArchElements.SlabElement(self.slab_properties, outline)` | 2026-09-03 |
| Höhe = Summe Schichtdicken | EX/…/Objects/Slab.py:245-258, 283-298 | `plane_ref = slab_props.GetPlaneReferences()` · `plane_ref.SetHeight(height)` | 2026-09-03 |
| Bodenplatte (Beispiel) | EX/PythonPartsExampleScripts/ArchitectureExamples/Objects/SlabFoundation.py:162-173, 211 | `AllplanArchElements.SlabFoundationProperties()` · `.PlaneReferences` · `AllplanArchElements.SlabFoundationElement(self.slab_properties, outline)` | 2026-09-03 |
| Lesen von PlaneReferences aus bestehender Decke | EX/…/Objects/SlabOpening.py:155-159 | `slab_ele = cast(AllplanArchEle.SlabElement, AllplanBaseEle.GetElement(self.slab_adapter_ele))` · `self.slab_plane_ref = slab_ele.Properties.PlaneReferences` | 2026-09-03 |
| Elementtabelle Geometrie | MAN/features/allplan_elements/#primary-components | „Slab → `SlabElement` → `Polygon2D`"; „Slab foundation → `SlabFoundationElement` → `Polygon2D`"; „Column → `ColumnElement` → `Point2D`" | 2026-09-03 |
| **D – Öffnungen** ||||
| `ArchEle.GeneralOpeningProperties` | API/NemAll_Python_ArchElements/GeneralOpeningProperties | `__init__(openingType: OpeningType)` · `__init__(openingProp: GeneralOpeningProperties)`; `PlaneReferences : PlaneReferences` (writable), `OpeningType : OpeningType` (writable), `Independent2DInteraction : bool`, `VisibleInViewSection3D : bool`; `GetGeometryProperties() -> VerticalOpeningGeometryProperties`; `GetSillProperties() -> VerticalOpeningSillProperties`; `GetOpeningSymbolsProperties() -> OpeningSymbolsProperties` | 2026-09-03 |
| `GeneralOpeningProperties.VisibleInViewSection3D` | API/…/GeneralOpeningProperties | „When set to False, the opening does NOT cut out the 3D model element of the parent architectural component… Relevant for recess only! Defaults to True." | 2026-09-03 |
| `ArchEle.OpeningType` | API/NemAll_Python_ArchElements/OpeningType | `Bases: Enum`; `eNiche = 0` („Niche"), `eRecess = 1` („Recess") | 2026-09-03 |
| `ArchEle.GeneralOpeningElement` | API/NemAll_Python_ArchElements/GeneralOpeningElement | `__init__()` · `__init__(wallOpeningProp: GeneralOpeningProperties, generalEle: BaseElementAdapter, startPnt: Point2D, endPnt: Point2D, drawPlacementPreview: bool)` · `__init__(wallOpeningProp, generalEle: BaseElementAdapter, groundPlanePolygon: Polygon2D, drawPlacementPreview: bool)`; `StartPoint : Point2D` | 2026-09-03 |
| `ArchEle.VerticalOpeningGeometryProperties` | API/NemAll_Python_ArchElements/VerticalOpeningGeometryProperties | Properties (alle writable): `Width: float`, `Depth: float`, `Shape: VerticalOpeningShapeType`, `ShapePolygon: Polygon2D`, `ProfilePath: str`, `RiseAtTop: float`, `RiseAtBottom: float`, `SegmentsAtTop: int`, `SegmentsAtBottom: int`; `__init__(element: VerticalOpeningGeometryProperties)` | 2026-09-03 |
| `ArchEle.VerticalOpeningShapeType` | EX/Library/…/Objects/GeneralOpening.pyp:33-37 | `eRectangle`, `eCircle`, `eSemiCircle`, `eArbitrary` (als `<EnumList>AllplanArchEle.VerticalOpeningShapeType.…`) | 2026-09-03 |
| Wandöffnung (Beispiel) | EX/PythonPartsExampleScripts/ArchitectureExamples/Objects/GeneralOpening.py:118-149 | `GeneralOpeningProperties(OpeningType.eNiche \| eRecess)` · `.VisibleInViewSection3D` · `.Independent2DInteraction` · `.PlaneReferences = build_ele.HeightSettings.value` · `GeneralOpeningElement(opening_prop, self.placement_ele, start.To2D, end.To2D, bool)` | 2026-09-03 |
| Polygonale Wandöffnung (Beispiel) | EX/…/Objects/GeneralOpeningsFor3DSolids.py:311-340 | `plane_ref.SetBottomPlaneSurface(bottom_surface)` · `plane_ref.SetTopPlaneSurface(top_surface)` · `geometry_prop.Shape = VerticalOpeningShapeType.eRectangle` · `geometry_prop.Depth = AxisElementAdapter(parent).GetThickness()` · `GeneralOpeningElement(opening_prop, opening_parent_ele, opening_polygon, False)` | 2026-09-03 |
| `.pyp`: Öffnungshöhe = PlaneReferences | EX/Library/Examples/PythonParts/ArchitectureExamples/Objects/GeneralOpening.pyp:106-113 | `<Name>HeightSettings</Name><ValueType>PlaneReferences</ValueType><ValueDialog>PlaneReferences</ValueDialog>` | 2026-09-03 |
| `.pyp`: `Depth` Default 0, max = Bauteildicke | EX/…/GeneralOpening.pyp:71-78 | `<Name>Depth</Name><Value>0</Value><MinValue>0</MinValue><MaxValue>ElementThickness</MaxValue>` | 2026-09-03 |
| `ArchEle.SlabOpeningProperties` | API/NemAll_Python_ArchElements/SlabOpeningProperties | `Bases: VerticalElementProperties, ArchBaseProperties`; `__init__(openingType: SlabOpeningType = eOpening)` · `__init__(openingProps: SlabOpeningProperties)`; `Independent2DInteraction : bool`; `GetOpeningType() -> SlabOpeningType`; `GetOpeningSymbolsProperties() -> OpeningSymbolsProperties` | 2026-09-03 |
| `ArchEle.SlabOpeningType` | API/NemAll_Python_ArchElements/SlabOpeningType | `Bases: Enum`; `eOpening = 0`, `eRecess = 1` | 2026-09-03 |
| `ArchEle.SlabOpeningElement` | API/NemAll_Python_ArchElements/SlabOpeningElement | `__init__()` · `__init__(slabOpeningProp: SlabOpeningProperties, placementPoint: Point3D, slabConnectionUUID: GUID)` · `__init__(slabOpeningProp, placementPoint: Point2D, slabConnectionUUID: GUID)`; `PlacementPoint : Point2D` (writable); `SetCommonProperties(commonProp: CommonProperties)`; `SetProperties(slabOpeningProp)` | 2026-09-03 |
| Deckenöffnung (Beispiel) | EX/PythonPartsExampleScripts/ArchitectureExamples/Objects/SlabOpening.py:213-235 | `SlabOpeningProperties(opening_type)` · `opening_props.PlaneReferences = build_ele.HeightSettings.value` · `opening_props.Independent2DInteraction` · `opening_props.CommonProperties` · `SlabOpeningElement(opening_props, pnt2d, self.slab_adapter_ele.GetModelElementUUID())` | 2026-09-03 |
| Deckenöffnung, Höhe nur bei Recess | EX/Library/Examples/PythonParts/ArchitectureExamples/Objects/SlabOpening.pyp:36-61 | `<ValueType>ConditionGroup</ValueType><Enable>OpeningType != "Opening"</Enable>` um `HeightSettings` | 2026-09-03 |
| Deckenöffnung ohne Selektion (Beispiel) | EX/…/Objects/SlabOpeningsFor3DSolids.py:299-309 | `AllplanArchEle.PlaneReferences(self.document, AllplanEleAdapter.BaseElementAdapter())` · `AllplanArchEle.SlabOpeningElement(opening_prop, AllplanGeo.Point2D(), slab.GetModelElementUUID())` | 2026-09-03 |
| Öffnungen = Sekundärbauteile | MAN/features/allplan_elements/#secondary-components | „Components that can only live within another component. E.g. a door opening can only exist in a wall. Deleting the wall will result in deletion of the opening."; Tabelle: „Niche, recess, slit, opening → `GeneralOpeningElement` (Construct it by start and end point)"; „Polygonal … → `GeneralOpeningElement` (Construct it by a polygon)"; „Recess, opening in slab → `SlabOpeningElement`" | 2026-09-03 |
| `EleAdapter.AxisElementAdapter` | EX/…/Objects/OpeningBase.py:139-145 | `AllplanEleAdapter.AxisElementAdapter(ele)`; `.IsNull()`, `.GetAxis()`, `.GetThickness()`, `.GetTiersCount()` | 2026-09-03 |
| **E – Teilbild / Struktur** ||||
| `BaseEle.DrawingFileService.GetActiveFileNumber` | API/NemAll_Python_BaseElements/DrawingFileService | `staticmethod GetActiveFileNumber() -> int` | 2026-09-03 |
| `DrawingFileService.GetFileState` | API/…/DrawingFileService | `GetFileState() -> list[tuple[int, DrawingFileLoadState]]` | 2026-09-03 |
| `DrawingFileService.LoadFile` | API/…/DrawingFileService | `LoadFile(doc: DocumentAdapter, fileIndex: int, loadState: DrawingFileLoadState)` | 2026-09-03 |
| `DrawingFileService.UnloadAll` / `UnloadFile` | API/…/DrawingFileService | `UnloadAll(doc: DocumentAdapter)` · `UnloadFile(...)` | 2026-09-03 |
| `DrawingFileService.GetDrawingFileName` | API/…/DrawingFileService | `staticmethod GetDrawingFileName(DrawingFileNumber: int) -> tuple[bool, str]` | 2026-09-03 |
| `DrawingFileService.RenameDrawingFile` | API/…/DrawingFileService | `staticmethod RenameDrawingFile(DrawingFileNumber: int, NewName: str) -> bool` | 2026-09-03 |
| `DrawingFileService.ShowDrawingFileDialog` | API/…/DrawingFileService | `staticmethod ShowDrawingFileDialog(doc: DocumentAdapter, singleSelection: bool, deactivateDerived: bool) -> list` — „Show a dialog to select drawing files"; Rückgabe „Indices of the selected drawing files" | 2026-09-03 |
| `DrawingFileService.SetScalingFactor` | API/…/DrawingFileService | `SetScalingFactor(doc, factor)` (im Beispiel `SetScalingFactor(doc, 20)`) | 2026-09-03 |
| `BaseEle.DrawingFileLoadState.ActiveForeground` | EX/PythonPartsExampleScripts/InteractorExamples/DrawingLayoutFileInteractor.py:183-192 | `drawing_file_serv.LoadFile(doc, nr, AllplanBaseElements.DrawingFileLoadState.ActiveForeground)` nach `UnloadAll(doc)` | 2026-09-03 |
| Teilbild-Service (Beispiel) | EX/PythonPartsExampleScripts/ServiceExamples/DrawingFile_LayoutFileService.py:83-93 | `AllplanBaseElements.DrawingFileService.GetDrawingFileName(nr)` · `…RenameDrawingFile(nr, name)` | 2026-09-03 |
| „nur Teilbilder der Bauwerksstruktur" | MAN/key_components/palette/parameter_with_dialog/#drawing-file | `<DeactivateDerived>` — „When set to True, only the drawing files from the **building structure** are available for selection. The derived structure is deactivated." | 2026-09-03 |
| `BaseEle.MoveElementsToDrawingFile` | API/NemAll_Python_BaseElements (Modulseite) | `MoveElementsToDrawingFile(doc: DocumentAdapter, elements: BaseElementAdapterList, targetDrawingFiletNr: int, viewProj: ViewWorldProjection)` | 2026-09-03 |
| `BaseEle.CopyElementsToDrawingFile` | API/NemAll_Python_BaseElements (Modulseite) | `CopyElementsToDrawingFile(doc, elements: BaseElementAdapterList, targetDrawingFiletNr: int, viewProj: ViewWorldProjection)` | 2026-09-03 |
| `EleAdapter.DocumentNameService` | API/NemAll_Python_IFW_ElementAdapter/DocumentNameService | `staticmethod GetActiveDocumentName() -> str`; `GetDocumentName(ele: BaseElementAdapter, withNumber: bool, withLabel: bool, delimiter: str) -> str`; `GetDocumentNameByFileIndex(fileIndex: int, withNumber, withLabel, delimiter) -> str`; `GetDocumentNameByFileNumber(...)`; `GetLoadedDocumentsNameData()` | 2026-09-03 |
| `EleAdapter.DocumentAdapter` | API/NemAll_Python_IFW_ElementAdapter/DocumentAdapter | `__init__()`; `GetDocumentID() -> int`; `GetScalingFactor() -> float` | 2026-09-03 |
| Klassenliste `NemAll_Python_IFW_ElementAdapter` | API/NemAll_Python_IFW_ElementAdapter (Modulseite) | vollständig: `ArchElementType, AssocViewElementAdapter, AxisElementAdapter, BaseElementAdapter, BaseElementAdapterChildElementsService, BaseElementAdapterList, BaseElementAdapterParentElementService, BaseElementAdapterService, BaseElementAdapterVector, DocumentAdapter, DocumentNameService, ElementAdapterType, ElementAdapterTypeData, ElementAdapterTypeGroup, GUID, PrecastPropertiesService, ReinforcementPropertiesReader` — **kein** BuildingStructure/Storey/Level | 2026-09-03 |
| Klassenliste `NemAll_Python_ArchElements` | API/NemAll_Python_ArchElements (Modulseite) | 61 Klassen + 12 Enums, vollständig abgerufen — **kein** BuildingStructure/Storey/Level/Insulation | 2026-09-03 |
| Kein Bauwerksstruktur-Symbol | Such-Index `https://pythonparts.allplan.com/2026/search/search_index.json` (10 319 Abschnitte) | Treffer für „BuildingStructure" = 0; „Storey" nur `RoomProperties.StoreyCode` + 1 Manual-Satz; „Geschoss" = 0 | 2026-09-03 |
| `EleAdapter.BaseElementAdapter` (Meta) | MAN/features/model_access/read_access/#descriptive-data | `GetDisplayName()`, `GetDrawingfileNumber()`, `GetElementAdapterType()`, `GetElementUUID()`, `GetModelElementUUID()`, `GetGeometry()`, `GetModelGeometry()`, `GetCommonProperties()`, `GetAttributes(readState)`, `GetDocument()` | 2026-09-03 |
| `EleAdapter.BaseElementAdapterParentElementService.GetParentElement` | EX/…/Objects/PolygonalGeneralOpening.py:174 · EX/…/ObjectModification/ModifyPlaneReferences.py:227 | `BaseElementAdapterParentElementService.GetParentElement(ele) -> BaseElementAdapter` | 2026-09-03 |
| `EleAdapter.BaseElementAdapterChildElementsService.GetTierNumber` | EX/PythonPartsExampleScripts/BasisExamples/ObjectModification/ModifyPlaneReferences.py:198 | `BaseElementAdapterChildElementsService.GetTierNumber(tier_adapter) -> int` | 2026-09-03 |
| `EleAdapter.BaseElementAdapter.FromGUID` | EX/…/ModifyPlaneReferences.py:193 | `BaseElementAdapter.FromGUID(uuid, document) -> BaseElementAdapter` | 2026-09-03 |
| Typ-UUIDs | EX/…/ModifyPlaneReferences.py:85-88 · EX/…/Objects/SlabOpening.py:132 | `AllplanEleAdapter.WallTier_TypeUUID`, `Column_TypeUUID`, `Beam_TypeUUID`, `Slab_TypeUUID` | 2026-09-03 |
| **F – Attribute / Material** ||||
| `ArchEle.ArchBaseProperties` | API/NemAll_Python_ArchElements/ArchBaseProperties | „Base class representing properties of all kinds of architectural components" | 2026-09-03 |
| `ArchBaseProperties.Material` | API/…/ArchBaseProperties | `Material : str` (property, writable); `GetMaterial() -> str`; `SetMaterial(material: str)` | 2026-09-03 |
| `ArchBaseProperties.Name` | API/…/ArchBaseProperties | `Name : str` (writable); `GetName() -> str`; `SetName(name: str)` | 2026-09-03 |
| `ArchBaseProperties.PlaneReferences` | API/…/ArchBaseProperties | `PlaneReferences : PlaneReferences` (writable); `GetPlaneReferences() -> PlaneReferences`; `SetPlaneReferences(planeRef: PlaneReferences)` | 2026-09-03 |
| `ArchBaseProperties.Surface` | API/…/ArchBaseProperties | `Surface : str` (writable); `SetSurface(surface: str)` | 2026-09-03 |
| `ArchBaseProperties` weitere | API/…/ArchBaseProperties | `Priority: int`, `Trade: int`, `CalculationMode: int`, `Factor: float`, `Hatch/Pattern/Filling/FaceStyle/BackgroundColor: int`, `Status`, `BitmapName: str`, `CircleDivision: int`, `CommonProperties`, `SurfaceElementProperties`, `LoadFromFavoriteFile()`, `RemoveCommonProperties()`, `ResetAreaElement()`, `SetShowAreaElementInGroundView()` | 2026-09-03 |
| Klassendiagramm ArchBaseProperties | MAN/features/allplan_elements/#primary-components | listet `+Material`, `+PlaneReferences`, `+Priority`, `+Trade`, `+Surface`, `+CalculationMode` als Member von `ArchBaseProperties` | 2026-09-03 |
| `PlaneReferences` an bestehendem Bauteil setzen | EX/PythonPartsExampleScripts/BasisExamples/ObjectModification/ModifyPlaneReferences.py:173-177 | `arch_properties = cast(AllplanArchElements.ArchBaseProperties, arch_element.Properties)` · `arch_properties.PlaneReferences = …` · `arch_element.Properties = arch_properties` · `AllplanBaseEle.ModifyElements(self.document, arch_elements)` | 2026-09-03 |
| `BasisEle.AllplanElement` | API/NemAll_Python_BasisElements/AllplanElement | `GetAttributes()`, `SetAttributes(...)`, `GetCommonProperties()`, `SetCommonProperties(...)`, `GetGeometryObject()`, `SetGeometryObject(...)`, `GetBaseElementAdapter()`, `SetBaseElementAdapter(...)`, `GetLabelElements()`, `SetLabelElements(...)`, `GetSubElementID()`, `SetDockingPointsKey(...)`; Properties `Attributes`, `CommonProperties`, `GeometryObject`, `BaseElementAdapter`, `LabelElements` | 2026-09-03 |
| `BaseEle.AttributeString` | API/NemAll_Python_BaseElements/AttributeString | `__init__()` · `__init__(id: int, value: str)` · `__init__(element: AttributeString)` | 2026-09-03 |
| `BaseEle.AttributeDouble` | API/NemAll_Python_BaseElements/AttributeDouble | `__init__()` · `__init__(id: int, value: float)` · Copy-Ctor | 2026-09-03 |
| `BaseEle.AttributeSet` | API/NemAll_Python_BaseElements/AttributeSet | `__init__()` · `__init__(elements: list)` · `__init__(element: AttributeSet)` | 2026-09-03 |
| `BaseEle.Attributes` | API/NemAll_Python_BaseElements/Attributes | `__init__()` · `__init__(elements: list)` („Attribute set element list") | 2026-09-03 |
| `AttributeInteger` / `AttributeEnum` / `AttributeStringVec` | MAN/features/attributes/element_attributes/#create-elements-with-attributes · EX/PythonPartsExampleScripts/PrecastExamples/MWSPlacement.py:69-77 | `AttributeInteger(attrid, int)`, `AttributeEnum(49, 0)`, `AttributeStringVec(attrid, list)` | 2026-09-03 |
| Attribute an Element hängen (Manual-Beispiel) | MAN/features/attributes/element_attributes/#create-elements-with-attributes | `attr_set = AllplanBaseElements.AttributeSet([...])` · `attributes = AllplanBaseElements.Attributes([attr_set])` · `model_element.SetAttributes(attributes)` | 2026-09-03 |
| `BaseEle.ElementsAttributeService.GetAttributes` | API/NemAll_Python_BaseElements/ElementsAttributeService | `GetAttributes(ele: BaseElementAdapter, readState: eAttibuteReadState = ReadAll) -> list` (Liste von `(id, value)`-Tupeln) | 2026-09-03 |
| `ElementsAttributeService.ChangeAttributes` | API/…/ElementsAttributeService | `ChangeAttributes(attributeDataList: list, elements: BaseElementAdapterList, setUndefAttrib: bool = False, setDeleteAttrib: bool = False) -> BaseElementAdapterList` | 2026-09-03 |
| `ElementsAttributeService.ChangeAttribute` | MAN/features/attributes/element_attributes/#setting-attributes | `ChangeAttribute(attrId, value, element_adapters, setUndefAttrib=False, setDeleteAttrib=False)` | 2026-09-03 |
| `BaseEle.eAttibuteReadState` | EX/PythonPartsExampleScripts/ModelObjectExamples/General/ShowObjectInformation.py:205 · EX/…/SelectionExamples/SelectObjectsByAttributeID.py:144 | `AllplanBaseEle.eAttibuteReadState.ReadAll`, `…ReadAllAndComputable` | 2026-09-03 |
| `BaseEle.AttributeService.GetAttributeID` | API/NemAll_Python_BaseElements/AttributeService | `GetAttributeID(doc: DocumentAdapter, attributeName: str) -> int` | 2026-09-03 |
| `AttributeService.GetAttributeName` | API/…/AttributeService | `GetAttributeName(doc: DocumentAdapter, attributeID: int) -> str` | 2026-09-03 |
| `AttributeService.GetAttributeType` / `GetDefaultValue` / `GetEnumValues` / `GetInputListValues` / `GetAttributeControlType` | EX/PythonPartsExampleScripts/ServiceExamples/AttributeService.py:70-81 | `attr_service.GetAttributeType(doc, id)`, `GetDefaultValue(doc, id)`, `GetEnumValues(doc, id)`, `GetInputListValues(doc, id)`, `GetAttributeControlType(doc, id)` | 2026-09-03 |
| `AttributeService.AddUserAttribute` | EX/…/ServiceExamples/AttributeService.py:127-137 | `AddUserAttribute(doc, AttributeType.names[...], name, defaultValue, minValue, maxValue, dim, AttributeControlType.names[...], listValues: AllplanUtil.VecStringList) -> int` (−1 = Fehler) | 2026-09-03 |
| `AttributeService.GetEnumIDFromValueString` | EX/PythonPartsExampleScripts/ArchitectureExamples/Objects/Beam.py:175 | `AllplanBaseElements.AttributeService.GetEnumIDFromValueString(120, value_str)` | 2026-09-03 |
| `BuildingElementAttributeList` | GS/BuildingElementAttributeList | `__init__() -> None`; `add_attribute(attribute_id: int, attribute_value: Any)`; `add_attribute_by_unit(attribute_id: int, attribute_value: Any)`; `add_attribute_list(attribute_list: list[Attribute])`; `add_attributes(attributes: list[tuple[int, Any]])`; `add_attributes_by_unit(...)`; `add_attributes_from_parameters(build_ele: BuildingElement)`; `get_attribute_list() -> list[Attribute]`; `get_attributes_list_as_tuples() -> list[tuple[int, Any]]`; `set_attributes_to_element(element: AllplanElement)`; `__iadd__` | 2026-09-03 |
| `BuildingElementAttributeList` (Beispiel) | EX/PythonPartsExampleScripts/BasisExamples/General/Attributes.py:109-113 | `attributes_list = BuildingElementAttributeList()` · `attributes_list.add_attributes_from_parameters(build_ele)` · `model_ele_list.set_element_attributes(-1, attributes_list.get_attribute_list())` | 2026-09-03 |
| Attribut-Nummern (Wand, real ausgelesen) | MAN/features/model_access/read_access/#attributes | `10 Allright_Comp_ID`, `12 Component ID`, `49 Status`, `83 Code text`, `120 Calculation mode`, `209 Trade`, `214 Component`, `220 Length`, `221 Thickness`, `222 Height`, `226 Net volume`, `229 Area`, `498 Object_name`, `508 Material`, `683 Ifc ID` | 2026-09-03 |
| `AttributeIdEnums` (Framework) | EX/PythonPartsExampleScripts/BasisExamples/PythonParts/PythonPartWithAttributes.py:145-150 | `AttributeIdEnums.LENGTH`, `AttributeIdEnums.THICKNESS`, `AttributeIdEnums.HEIGHT` (via `add_attribute_by_unit`) | 2026-09-03 |
| `BaseEle.CommonProperties` | API/NemAll_Python_BaseElements/CommonProperties | `__init__()`; `GetGlobalProperties()`; Properties `Color: int`, `Layer: int`, `Pen: int`, `Stroke: int` (writable) | 2026-09-03 |
| `BaseEle.LayerService` | API/NemAll_Python_BaseElements/LayerService | `staticmethod GetIDByShortName(shortName: str, doc: DocumentAdapter) -> int`; `GetNameByID(layerID: int, documentID: int) -> str`; `GetShortNameByID(layerID: int, documentID: int) -> str`; `LoadFromFavoriteFile`, `SaveToFavoriteFile` | 2026-09-03 |
| `Settings.AllplanGlobalSettings.GetCurrentCommonProperties` | EX/PythonPartsExampleScripts/ArchitectureExamples/Objects/Wall.py:53 | `AllplanSettings.AllplanGlobalSettings.GetCurrentCommonProperties()` | 2026-09-03 |
| **G – Brüstung/Sturz-Alternative** ||||
| `ArchEle.BeamProperties` | API/NemAll_Python_ArchElements/BeamProperties | `Bases: ArchBaseProperties`; `SetAxis(...)`, `IsStartNewJoinedBeamGroup: bool`, `ShapeType: ShapeType`, `Width: float` („Width of the rectangular cross-section shape"), `ProfileFullName: str`, `GetProfileFullName()`, `SetProfileFullName(...)` | 2026-09-03 |
| `ArchEle.BeamElement` | API/NemAll_Python_ArchElements/BeamElement | `__init__()` · `__init__(beamProp: BeamProperties, axis: object)` · Copy-Ctor; `Properties` | 2026-09-03 |
| Unterzug (Beispiel) | EX/PythonPartsExampleScripts/ArchitectureExamples/Objects/Beam.py:158-181, 235 | `beam_prop = AllplanArchElements.BeamProperties()` · `beam_prop.SetAxis(self.axis_properties)` · `beam_prop.PlaneReferences = …` · `beam_prop.ShapeType = …` · `beam_prop.Width = …` · `AllplanArchElements.BeamElement(self.beam_properties, axis)` | 2026-09-03 |
| **I – Framework / Kontrakte / Einheiten** ||||
| `create_element` (Standard-Kontrakt) | MAN/key_components/script/standard_pythonpart/#StandardPythonPart.create_element | `create_element(build_ele: BuildingElement, doc: DocumentAdapter) -> CreateElementResult` | 2026-09-03 |
| `check_allplan_version` | MAN/key_components/script/standard_pythonpart/#StandardPythonPart.check_allplan_version | `check_allplan_version(build_ele: BuildingElement, version: float) -> bool` | 2026-09-03 |
| `create_script_object` | MAN/key_components/script/script_object/#ScriptObjectPythonPart.create_script_object | `create_script_object(build_ele: BuildingElement, script_object_data: BaseScriptObjectData) -> BaseScriptObject` | 2026-09-03 |
| `create_interactor` | MAN/key_components/script/interactor_pythonpart/#InteractorPythonPart.create_interactor | `create_interactor(interactor_data: BaseInteractorData) -> Interactor` (neue Signatur; 3- und 7-Argument-Varianten „nothing wrong in using them, but the newest and recommended signature is the one with one argument") | 2026-09-03 |
| `create_preview` | MAN/key_components/script/interactor_pythonpart/#InteractorPythonPart.create_preview | `create_preview(build_ele: BuildingElement, doc: DocumentAdapter) -> CreateElementResult` | 2026-09-03 |
| `create_docking_points` | MAN/key_components/script/standard_pythonpart/#StandardPythonPart.create_docking_points | `create_docking_points(build_ele, doc) -> Tuple[List[Tuple[str, Point3D]], List[...], List[...]]` | 2026-09-03 |
| `CreateElementResult` | GS/CreateElementResult | Datenklasse: `elements: ModelEleList`, `handles: list[HandleProperties]`, `preview_elements: ModelEleList`, `placement_point: Point2D\|Point3D\|None`, `multi_placement: bool`, `preview_symbols`, `reinf_rearrange`, `handle_placement_geo: list[Any]`, `as_static_preview: bool`, `connect_to_ele`, `uuid_parameter_name: str`, `elements_to_delete`, `append_reinf_pos_nr: bool`, `elements_to_hide`, `elements_to_show`, `hidden_preview_elements`, `visible_preview_elements`; `is_empty() -> bool` | 2026-09-03 |
| `TypeCollections.ModelEleList` | TC/ModelEleList | `Bases: list[AllplanElement]`; `__init__(com_prop: CommonProperties = GetCurrentCommonProperties(), element: AllplanElement\|None = None, trans_stack: TransformationStack = ...)`; `append(allplan_ele: AllplanElement)`; `append_geometry_2d(...)`; `append_geometry_3d(geo_ele, com_prop=None, section_surface_ele_props=None, use_trans_matrix=True)`; `set_element_attributes(index: int, attributes: list[Attribute])`; `set_common_properties(com_prop)`; `set_layer(layer: int\|str, document: DocumentAdapter)`; `set_color(int)`, `set_pen(int)`, `set_stroke(int)` | 2026-09-03 |
| `BaseEle.CreateElements` | API/NemAll_Python_BaseElements (Modulseite) | `CreateElements(doc: DocumentAdapter, insertionMat: Matrix3D, modelEleList: list, modelUuidList: list, assoRefObj: object, appendReinfPosNr: bool = True, createUndoStep: bool = True) -> BaseElementAdapterList` | 2026-09-03 |
| `BaseEle.ModifyElements` | API/NemAll_Python_BaseElements (Modulseite) | `ModifyElements(doc: DocumentAdapter, modelEleList: list)` | 2026-09-03 |
| `BaseEle.GetElement` / `GetElements` | API/NemAll_Python_BaseElements (Modulseite) | `GetElement(element: BaseElementAdapter) -> object` · `GetElements(elementsList: BaseElementAdapterList) -> list` | 2026-09-03 |
| `BaseEle.DrawElementPreview` | EX/…/Objects/Column.py:145-146 · EX/…/Objects/SlabOpening.py:203-204 | `AllplanBaseEle.DrawElementPreview(document, Matrix3D(), elements, bool, None)` | 2026-09-03 |
| `IFW.SelectElementsService.SelectByPolygon` | EX/PythonPartsExampleScripts/ArchitectureExamples/Objects/PolygonalGeneralOpening.py:160-166 | `AllplanIFW.SelectElementsService.SelectByPolygon(document, polygon2d, viewWorldProjection, AllplanIFW.SelectElementsService.eSelectCondition.SELECT_ALL, elementsQuery, True)` | 2026-09-03 |
| Einheit Millimeter | MAN/features/geometry/#point | „The coordinates are always given in millimeters." (gilt auch für Vector, MAN/features/geometry/#vector) | 2026-09-03 |
| Winkel in Radiant | MAN/features/geometry/#angle | „Its value is given in radians"; `AllplanGeo.Angle(math.pi/2)`, `AllplanGeo.Angle.FromDeg(90)` | 2026-09-03 |
| `Geo.Angle.Deg` | EX/…/StructuralFramingExamples/StructuralColumn.py:79-81 | `angle = AllplanGeo.Angle(); angle.Deg = build_ele.Angle.value` | 2026-09-03 |
| `Geo.ConvertTo2D` | EX/…/Objects/Wall.py:119 · EX/…/Objects/Slab.py:142 | `AllplanGeometry.ConvertTo2D(polygon3d\|line3d) -> tuple[bool, Polygon2D\|Line2D]` | 2026-09-03 |
| `Geo.Polyhedron3D.CreateCuboid` | EX/…/Objects/Wall.py:54 · MAN/features/connections/#plane-connection | `Polyhedron3D.CreateCuboid(length, width, height)` bzw. `CreateCuboid(Point3D, Point3D)` | 2026-09-03 |
| `Geo.Move` | EX/PythonPartsExampleScripts/BasisExamples/General/PlaneConnection.py:137 | `AllplanGeo.Move(geo, AllplanGeo.Vector3D(0, 0, z))` | 2026-09-03 |
| PythonPart = Container (nicht nativ) | MAN/features/pythonpart/#pythonpart | „A PythonPart as an element in the DF can be understood as a **container**, encapsulating AllplanElements…" | 2026-09-03 |
| `PythonPartUtil` | MAN/features/pythonpart/#create-pythonpart · EX/…/PlaneReferencesControls.py:137-141 | `PythonPartUtil(common_prop)`; `add_pythonpart_view_2d3d(model_ele_list)`; `create_pythonpart(build_ele, placement_matrix=..., local_placement_matrix=...)`; `add_attribute_list(attribute_list)`; `get_pythonpart(build_ele, placement_matrix=..., type_uuid=..., type_display_name=...)` | 2026-09-03 |
| Warnung PlaneReferences im PythonPart | MAN/key_components/palette/parameter_with_dialog/#plane-references | „When the planes are changed by the user in floor manager, all PythonParts with plane connections … are checked and, if necessary, updated. … make sure, that reactivating your PythonPart with double-click and hitting Esc directly after, leads to a clean termination. If that is not the case, ALLPLAN will get stuck during the update." | 2026-09-03 |
| Performance-Warnung ModifyElements | MAN/features/model_access/element_modification/#specific-modification | „As writing elements into the database is a relatively slow process, limit the number of `ModifyElements` function calls." | 2026-09-03 |
| **Versionen** ||||
| `SlabFoundationElement` neu in 2026 | `https://pythonparts.allplan.com/2026/release_notes/` (Abschnitt WIP-3) | „With the newly exposed class `SlabFoundationElement` it is now possible to create and modify slab foundation using Python API." | 2026-09-03 |
| `Move/CopyElementsToDrawingFile` neu | release_notes (WIP-6) | „The functionality of moving/copying elements between drawing files has been exposed to Python API. See the new functions: `MoveElementsToDrawingFile()` and `CopyElementsToDrawingFile()`." | 2026-09-03 |
| Modifikation Wand/Stütze/Unterzug/Öffnungen neu | release_notes (WIP-1, WIP-2) | Tabelle: `BeamElement`, `ColumnElement`, `DoorOpeningElement`, `GeneralOpeningElement`, `WallElement`, `WindowOpeningElement`, `BlockFoundationElement`, `RoomElement` modifizierbar | 2026-09-03 |
| Python-Version 2026 | release_notes (2026-0-3) | „The version of Python has been updated to **3.13.9**" | 2026-09-03 |
| `<Parameters>`-Container ab WIP-4 | release_notes (WIP-4) | „From now on, all the parameters are grouped within one `<Parameters>` container … XML structured without this container tag still work." | 2026-09-03 |
| PYP-Schema-URL | EX/Library/Examples/PythonParts/ArchitectureExamples/Objects/Wall.pyp:2 | `xsi:noNamespaceSchemaLocation="https://pythonparts.allplan.com/2026/schemas/PythonPart.xsd"` | 2026-09-03 |
| **J – Dateiablage** ||||
| Ablagestruktur `.pyp` / `.py` | MAN/key_components/#file-locations | `std\ \| usr\<USER_NAME>\ \| prj\<PROJECT_NAME>\` → `Library\<Gruppe>\X.pyp` (+ `X.png`, `X_deu.xml`) und `PythonPartsScripts\<Gruppe>\X.py` | 2026-09-03 |
| `etc\` nicht beschreiben | MAN/key_components/#file-locations | „Do not use the `...\etc\` directory to store any of your files as it is the property of ALLPLAN and its content can be deleted or moved during an update!" | 2026-09-03 |
| `<Script><Name>` relativ zu PythonPartsScripts | MAN/key_components/#file-structure | „Path to the PY file relative to `PythonPartsScripts` directory. There are three: one in prj, one in std and one in usr directory. Python will look in all of them to find your PY file. **In exactly this order.**" | 2026-09-03 |
| `<Script>`-Tags | EX/Library/Examples/PythonParts/ArchitectureExamples/Objects/Wall.pyp:3-8 | `<Name>ArchitectureExamples\Objects\Wall.py</Name>`, `<Title>`, `<Version>`, `<ReadLastInput>` | 2026-09-03 |
| `sys.path`-Ordner | MAN/getting_started/#python-environment | `Etc\PythonParts-site-packages`, `Etc\PythonPartsFramework`, `Etc\PythonPartsFramework\GeneralScripts`, `Etc\PythonPartsScripts`, `Prj\<Projekt>\PythonPartsScripts`, `Std\PythonParts-site-packages`, `Std\PythonPartsScripts`, `Usr\<User>\PythonParts-site-packages`, `Usr\<User>\PythonPartsScripts`, `Prg` | 2026-09-03 |
| Site-Package-Ladereihenfolge | MAN/getting_started/#site-packages | `std\PythonParts-site-packages` → `usr\<username>\PythonParts-site-packages` → `etc\PythonParts-site-packages` | 2026-09-03 |
| Python-Paket statt Einzeldatei | MAN/key_components/#file-locations | Ordner `PythonPartsScripts\<Gruppe>\<Name>\__init__.py` wird als Modul behandelt; `.pyp` zeigt weiter auf `<Name>.py` | 2026-09-03 |
| `.allep`-Paketinhalt | MAN/for_developer/delivery/#create-a-release | ZIP aus `Library/ PythonPartsScripts/ install-config.yml` | 2026-09-03 |
| SDK-Repo-Struktur | `/tmp/claude-0/-home-user-plan2allplan/cec3c10c-725f-583f-94fd-2cc650e8bb6c/scratchpad/pythonparts-sdk/` (`ls`) | `Library/`, `PythonPartsScripts/`, `PythonPartsActionbar/`, `install-config.yml`, `requirements.in`, `LICENSE` | 2026-09-03 |
| `Settings.AllplanPaths.GetPythonPartsEtcPath` | EX/…/Objects/Column.py:60-62 · EX/…/PlaneReferencesControls.py:58-60 | `AllplanSettings.AllplanPaths.GetPythonPartsEtcPath() -> str` | 2026-09-03 |

### Bewusst NICHT aufgenommen (nicht gelesen / nicht auffindbar)

| Gesuchtes Symbol | Wo gesucht | Ergebnis |
|---|---|---|
| `BuildingStructure`, `Storey`, `BuildingLevel`, `StructureElement` | Such-Index der gesamten Doku 2026; Modulseiten `NemAll_Python_IFW_ElementAdapter`, `NemAll_Python_ArchElements`, `NemAll_Python_BaseElements` | **existiert nicht** in der Python-API 2026 |
| `ShapeGeometryPropertiesParameterUtil`, `VerticalOpeningGeometryPropertiesParameterUtil`, `OpeningSillPropertiesParameterUtil`, `OpeningSymbolsPropertiesParameterUtil` | Beispiel-Klon (`find`), Doku-Such-Index | nur importiert, Quelltext liegt in `…\Etc\PythonPartsFramework\` der Installation → nicht gelesen, nicht empfohlen |
| `etc\PythonPartsFramework\ParameterIncludes\ShapeGeometryProperties.incl`, `OpeningSillProperties.incl`, `GeneralOpeningSymbolsProperties.incl`, `OpeningSymbolsProperties.incl` | Beispiel-Klon | nur als `<Value>`-Pfad in den `.pyp` referenziert, Inhalt nicht gelesen |
| Bedeutung von `eComponentsBottomPlane`, `eComponentsTopPlane`, `eTopFixed`, `eBottomFixed` | API/…/PlaneReferences | nur Enum-Namen dokumentiert, keine Beschreibung → offene Frage O-1 |
| Herkunft von `ReferencePlaneID.ModelGuid` / `PlaneId` | API/…/ReferencePlaneID, Such-Index | nicht dokumentiert → offene Frage O-2 |
| Indexbasis von `SlabProperties.GetSlabTierProperties` | API/…/SlabProperties | Doku schweigt; Beispiel nutzt 0-basiert → offene Frage O-6 |
| `AllplanSettings.AllplanPaths`-Getter für `Std`/`Usr`-Pfad | nur `GetPythonPartsEtcPath()` in Beispielen gelesen | weitere Getter nicht geprüft → offene Frage O-7 |
| Allplan 2027 API | – | nicht abgefragt, keine Aussage möglich |

### IFC / ifcopenshell

## IFC-Quellenprotokoll (evidence_ifc.md)

Recherche-Agent `research-ifc`. Umgebung: ifcopenshell 0.8.5, installiert unter
`/usr/local/lib/python3.11/dist-packages/ifcopenshell` (Modulpfad `IOS/` unten).
Alle Signaturen wurden entweder aus dem installierten Quellcode (Docstring + `def`-Zeile)
oder von der zitierten URL gelesen. Datum aller Einträge: 2026-09-03.

Abkürzung: `IOS/<pfad>` = `/usr/local/lib/python3.11/dist-packages/ifcopenshell/<pfad>`

| Symbol | Quelle (URL oder Modulpfad) | gefundene Signatur | Datum |
|---|---|---|---|
| `ifcopenshell.version` | IOS/`__init__.py` (Laufzeitwert) | `"0.8.5"` | 2026-09-03 |
| `ifcopenshell.api.project.create_file` | IOS/`api/project/create_file.py` | `def create_file(version: ifcopenshell.util.schema.IFC_SCHEMA = "IFC4") -> ifcopenshell.file` | 2026-09-03 |
| `ifcopenshell.api.root.create_entity` | IOS/`api/root/create_entity.py` | `def create_entity(file, ifc_class: str = "IfcBuildingElementProxy", predefined_type: Optional[str] = None, name: Optional[str] = None) -> ifcopenshell.entity_instance` | 2026-09-03 |
| `ifcopenshell.api.unit.add_si_unit` | IOS/`api/unit/add_si_unit.py` | `def add_si_unit(file, unit_type: str = "LENGTHUNIT", prefix: Optional[str] = None) -> ifcopenshell.entity_instance`; unit_type u.a. LENGTHUNIT/AREAUNIT/VOLUMEUNIT; prefix u.a. MILLI | 2026-09-03 |
| `ifcopenshell.api.unit.assign_unit` | IOS/`api/unit/assign_unit.py` | `def assign_unit(file, units: Optional[list]=None, length=None, area=None, volume=None) -> ifcopenshell.entity_instance`; Default ohne Argumente: Millimeter (LENGTHUNIT MILLI), m² (AREAUNIT), m³ (VOLUMEUNIT) – Kommentar im Code: "convenience function" | 2026-09-03 |
| `ifcopenshell.api.context.add_context` | IOS/`api/context/add_context.py` | `def add_context(file, context_type=None, context_identifier=None, target_view=None, target_scale=None, parent=None) -> ifcopenshell.entity_instance`; context_type nur "Model"/"Plan"; Subcontext braucht `parent` | 2026-09-03 |
| `ifcopenshell.api.aggregate.assign_object` | IOS/`api/aggregate/assign_object.py` | `def assign_object(file, products: list, relating_object) -> Union[entity_instance, None]`; Doku: Project→Site→Building→Storey via Aggregation | 2026-09-03 |
| `ifcopenshell.api.spatial.assign_container` | IOS/`api/spatial/assign_container.py` | `def assign_container(file, products: list, relating_structure) -> Union[entity_instance, None]`; physische Elemente via Containment in Storey/Space | 2026-09-03 |
| `ifcopenshell.api.geometry.add_wall_representation` | IOS/`api/geometry/add_wall_representation.py` | `def add_wall_representation(file, context, length=1.0, height=3.0, direction_sense="POSITIVE", offset=0.0, thickness=0.2, x_angle=0.0, clippings=None, booleans=None) -> ifcopenshell.entity_instance` (IfcShapeRepresentation, SweptSolid/Clipping) | 2026-09-03 |
| `ifcopenshell.api.geometry.add_axis_representation` | IOS/`api/geometry/add_axis_representation.py` | `def add_axis_representation(file, context, axis: tuple[COORD, COORD]) -> ifcopenshell.entity_instance`; Start=min lokal X, Ende=max lokal X für Wände | 2026-09-03 |
| `ifcopenshell.api.geometry.add_profile_representation` | IOS/`api/geometry/add_profile_representation.py` | `def add_profile_representation(file, context, profile, depth=1.0, cardinal_point=5, clippings=None, placement_zx_axes=(None,None)) -> ifcopenshell.entity_instance` | 2026-09-03 |
| `ifcopenshell.api.geometry.add_slab_representation` | IOS/`api/geometry/add_slab_representation.py` | `def add_slab_representation(file, context, depth=0.2, direction_sense="POSITIVE", offset=0.0, x_angle=0.0, clippings=None, polyline=None) -> ifcopenshell.entity_instance`; `polyline` = einfaches Polygon OHNE Löcher | 2026-09-03 |
| `ifcopenshell.api.geometry.assign_representation` | IOS/`api/geometry/assign_representation.py` | `def assign_representation(file, product, representation) -> None` | 2026-09-03 |
| `ifcopenshell.api.geometry.edit_object_placement` | IOS/`api/geometry/edit_object_placement.py` | `def edit_object_placement(file, product, matrix: Optional[np.ndarray]=None, is_si: bool=True, should_transform_children: bool=False) -> ifcopenshell.entity_instance`; nur lokale Placements, kein Grid/Linear | 2026-09-03 |
| `ifcopenshell.api.profile.add_parameterized_profile` | IOS/`api/profile/add_parameterized_profile.py` | `def add_parameterized_profile(file, ifc_class: str, profile_type: str="AREA") -> ifcopenshell.entity_instance`; ruft intern nur `file.create_entity(ifc_class, ProfileType=profile_type)` auf, Attribute (z.B. `Radius`, `XDim`/`YDim`) danach manuell setzen | 2026-09-03 |
| `ifcopenshell.api.profile.add_arbitrary_profile_with_voids` | IOS/`api/profile/add_arbitrary_profile_with_voids.py` | `def add_arbitrary_profile_with_voids(file, outer_profile: SequenceOfVectors, inner_profiles: list[SequenceOfVectors], name: Optional[str]=None) -> ifcopenshell.entity_instance` → IfcArbitraryProfileDefWithVoids; **Bug in 0.8.5**: outer_curve wird immer als `IfcCartesianPointList3D` erzeugt (Code-Zeile `outer_curve = self.file.create_entity("IfcIndexedPolyCurve", (self.file.create_entity("IfcCartesianPointList3D", ...)))`), auch bei 2D-Input → verletzt `IfcArbitraryClosedProfileDef.WR1` (outercurve.Dim==2), von `ifcopenshell.validate.validate()` bestätigt (siehe Probe-Lauf im Bericht) | 2026-09-03 |
| `ifcopenshell.api.feature.add_feature` | IOS/`api/feature/add_feature.py` | `def add_feature(file, feature: ifcopenshell.entity_instance, element: ifcopenshell.entity_instance) -> ifcopenshell.entity_instance`; ersetzt das in älteren Versionen dokumentierte `ifcopenshell.api.void.add_opening` (in 0.8.5 existiert kein `api/void`-Modul mehr, geprüft per `ls api/`) → erzeugt `IfcRelVoidsElement` für `IfcOpeningElement` | 2026-09-03 |
| `ifcopenshell.api.material.add_material` | IOS/`api/material/add_material.py` | `def add_material(file, name: Optional[str]=None, category: Optional[str]=None, description: Optional[str]=None) -> ifcopenshell.entity_instance`; Kategorien-Liste u.a. 'concrete','steel','block' | 2026-09-03 |
| `ifcopenshell.api.material.add_material_set` | IOS/`api/material/add_layer.py` (Docstring-Beispiel) | `ifcopenshell.api.material.add_material_set(model, name=..., set_type="IfcMaterialLayerSet")` | 2026-09-03 |
| `ifcopenshell.api.material.add_layer` | IOS/`api/material/add_layer.py` | `def add_layer(file, layer_set, material, name: Optional[str]=None) -> ifcopenshell.entity_instance` (IfcMaterialLayer) | 2026-09-03 |
| `ifcopenshell.api.material.edit_layer` | IOS/`api/material/add_layer.py` (Docstring-Beispiel) | `ifcopenshell.api.material.edit_layer(model, layer=layer, attributes={"LayerThickness": 13})` | 2026-09-03 |
| `ifcopenshell.api.material.assign_material` | IOS/`api/material/assign_material.py` | `def assign_material(file, products: list, type: MATERIAL_TYPE="IfcMaterial", material: Optional[entity_instance]=None) -> Union[entity_instance, list, None]`; `type` u.a. "IfcMaterialLayerSet" (nur an Types), "IfcMaterialLayerSetUsage" (nur an Occurrences, Material wird vom Type abgeleitet) | 2026-09-03 |
| `ifcopenshell.api.type.assign_type` | IOS/`api/type/assign_type.py` | `def assign_type(file, related_objects: list, relating_type, should_map_representations=True) -> Union[entity_instance, None]` | 2026-09-03 |
| `ifcopenshell.api.pset.add_pset` | IOS/`api/pset/add_pset.py` | `def add_pset(file, product, name: str, ifc2x3_subclass: Optional[str]=None) -> ifcopenshell.entity_instance` | 2026-09-03 |
| `ifcopenshell.api.pset.edit_pset` | IOS/`api/pset/edit_pset.py` | `def edit_pset(file, pset, name: Optional[str]=None, properties: Optional[dict]=None, pset_template=None, should_purge: bool=True) -> None`; `None`-Wert löscht Property, Datentyp aus buildingSMART-Template abgeleitet, sonst aus Python-Typ | 2026-09-03 |
| `ifcopenshell.open` | https://docs.ifcopenshell.org/ifcopenshell-python/code_examples.html; verifiziert per Probe-Lauf | `ifcopenshell.open(path) -> ifcopenshell.file` | 2026-09-03 |
| `ifcopenshell.file.by_type` | Probe-Lauf (Laufzeitverhalten) | `file.by_type("IfcWallStandardCase") -> list[entity_instance]` | 2026-09-03 |
| `ifcopenshell.geom.settings` / `ifcopenshell.geom.create_shape` | IOS/`geom/main.py` (Docstring von `create_shape`) | `def create_shape(settings: settings, inst: entity_instance, repr: Optional[entity_instance]=None, geometry_library: GEOMETRY_LIBRARY="opencascade") -> ...`; `inst`=IfcProduct → `ShapeElementType` mit `.geometry` | 2026-09-03 |
| `ifcopenshell.util.shape.get_vertices` | Probe-Lauf (Laufzeitverhalten, `import ifcopenshell.util.shape`) | `get_vertices(geometry) -> numpy.ndarray[N,3]` | 2026-09-03 |
| `ifcopenshell.validate.validate` | IOS/`validate.py` (Docstring von `validate`) | `def validate(f: Union[ifcopenshell.file, str], logger: Union[Logger, json_logger], express_rules=False) -> None`; empfiehlt Dateipfad statt File-Objekt für vollständige Fehlerdiagnose | 2026-09-03 |
| `ifcopenshell.validate.json_logger` | IOS/`validate.py` (Docstring von `validate`) | `logger = ifcopenshell.validate.json_logger()`; Ergebnisse in `logger.statements` (Liste von Dicts mit level/message/type/instance/attribute) | 2026-09-03 |
| `IfcWallStandardCase` (Schema-Element in IFC4) | IOS/`ifcopenshell_wrapper.schema_by_name("IFC4").declaration_by_name("IfcWallStandardCase")` (Laufzeitprüfung) | Existiert in IFC4 (`<entity IfcWallStandardCase>`), Subtype von IfcWall | 2026-09-03 |
| `IfcSlabTypeEnum`, `IfcColumnTypeEnum`, `IfcWallTypeEnum` (Enum-Werte) | IOS/`ifcopenshell_wrapper.schema_by_name("IFC4")` (Laufzeitprüfung, `.enumeration_items()`) | Slab: FLOOR/ROOF/LANDING/BASESLAB/USERDEFINED/NOTDEFINED; Column: COLUMN/PILASTER/…; Wall: MOVABLE/PARAPET/PARTITIONING/…/SOLIDWALL/STANDARD/… | 2026-09-03 |
| `IfcArbitraryProfileDefWithVoids` (Schema-Entität) | https://ifcopenshell.github.io (Referenz) + IOS/`util/schema/ifc4_entities.json` | "defines an arbitrary closed two-dimensional profile with holes … outer boundary and inner boundaries" | 2026-09-03 |
| IFC-Import-Mapping Allplan (Wand/Decke/Stütze/Öffnung, Proxy-Fallback, Einheiten) | https://help.allplan.com/Allplan/2023-0/1033/Allplan/320465.htm ("IFC Import Settings" (advanced) dialog box) | Wände: IfcWallStandardCase (gerade) / IfcWall (rund, frei, Elementwand), Mehrschichtwände teilbar; Decken: IfcSlab; Stützen: IfcColumn; Öffnungen: IfcOpening (Fenster/Tür/Deckenöffnung/Nische/Aussparung); Nicht erkannte Objekte → IfcBuildingElementProxy; Einheit wird aus Quelldatei übernommen, intern rechnet Allplan in Metern; Geschosszuordnung nur beim Export einstellbar (Default deaktiviert) | 2026-09-03 |

### Offene / widersprüchliche Punkte (nicht in Tabelle, da keine belastbare Quelle gefunden)

- Keine offizielle Allplan-Dokumentation gefunden, die bestätigt, ob Allplan 2026 beim
  **Import** zwingend eine Axis-Representation (Model/Axis oder Plan/Axis Subcontext)
  verlangt, um eine Wand als natives Wand-Objekt (statt Proxy) zu erkennen, oder ob eine
  reine Body/SweptSolid-Repräsentation ausreicht. Die zitierte Allplan-Hilfeseite
  beschreibt nur die Mapping-Regeln (Klassenname → Allplan-Objekttyp), nicht die
  geometrischen Mindestanforderungen.
- Keine Quelle (Allplan-Hilfe oder Forum) explizit für Allplan **2026** gefunden; die
  zitierte Hilfeseite ist für 2023-0. Funktionsumfang der IFC-Importfilter wird als
  stabil angenommen, aber nicht für 2026 verifiziert.

### Extraktion (ezdxf, pymupdf, opencv, shapely)

## Quellenprotokoll – Extraktion aus Architektenplänen (ezdxf/pymupdf/opencv/shapely)

Nur Symbole, die in dieser Session tatsächlich per `help()`/`inspect.signature()`/Quelltext der
installierten Bibliothek oder per offizieller Dokumentation gelesen wurden. Installierte Versionen:
ezdxf 1.4.4, pymupdf (fitz) 1.28.2, opencv-python-headless 5.0.0, shapely 2.1.2.

| Symbol | Quelle (URL oder Modulpfad) | gefundene Signatur | Datum |
|---|---|---|---|
| `ezdxf.readfile` | Modulpfad `/usr/local/lib/python3.11/dist-packages/ezdxf/__init__.py` (installiert, `inspect.signature`) | `readfile(filename: str \| os.PathLike, encoding: Optional[str]=None, errors: str='surrogateescape') -> Drawing` | 2026-09-03 |
| `ezdxf.new` | Modulpfad `ezdxf/__init__.py` (`inspect.signature`) | `new(dxfversion: str='AC1027', setup: Union[str,bool,Sequence[str]]=False, units: int=6) -> Drawing` | 2026-09-03 |
| `ezdxf.document.Drawing.modelspace` | Modulpfad `ezdxf/document.py` (`inspect.signature`) | `modelspace(self) -> Modelspace` | 2026-09-03 |
| `ezdxf.document.Drawing.saveas` | Modulpfad `ezdxf/document.py` (`inspect.signature`) | `saveas(self, filename: Union[os.PathLike,str], encoding: Optional[str]=None, fmt: str='asc') -> None` | 2026-09-03 |
| `ezdxf.document.Drawing.layers` (Property → `LayerTable`) | Modulpfad `ezdxf/document.py` (`inspect.signature` auf Property-Getter) | `-> LayerTable` | 2026-09-03 |
| `ezdxf.layouts.Modelspace` (MRO) | Modulpfad `ezdxf/layouts/layout.py`, `ezdxf/layouts/base.py`, `ezdxf/graphicsfactory.py` (`inspect`) | MRO: `Modelspace → Layout → BaseLayout → _AbstractLayout → CreatorInterface` | 2026-09-03 |
| `CreatorInterface.add_line` | Modulpfad `ezdxf/graphicsfactory.py` (`inspect.signature`) | `add_line(self, start: UVec, end: UVec, dxfattribs=None) -> Line` | 2026-09-03 |
| `CreatorInterface.add_lwpolyline` | Modulpfad `ezdxf/graphicsfactory.py` (`inspect.signature`) | `add_lwpolyline(self, points: Iterable[UVec], format: str='xyseb', *, close: bool=False, dxfattribs=None) -> LWPolyline` | 2026-09-03 |
| `CreatorInterface.add_polyline2d` | Modulpfad `ezdxf/graphicsfactory.py` (`inspect.signature`) | `add_polyline2d(self, points: Iterable[UVec], format: Optional[str]=None, *, close: bool=False, dxfattribs=None) -> Polyline` | 2026-09-03 |
| `CreatorInterface.add_circle` | Modulpfad `ezdxf/graphicsfactory.py` (`inspect.signature`) | `add_circle(self, center: UVec, radius: float, dxfattribs=None) -> Circle` | 2026-09-03 |
| `CreatorInterface.add_arc` | Modulpfad `ezdxf/graphicsfactory.py` (`inspect.signature`) | `add_arc(self, center: UVec, radius: float, start_angle: float, end_angle: float, is_counter_clockwise: bool=True, dxfattribs=None) -> Arc` | 2026-09-03 |
| `CreatorInterface.add_hatch` | Modulpfad `ezdxf/graphicsfactory.py` (`inspect.signature`) | `add_hatch(self, color: int=7, dxfattribs=None) -> Hatch` | 2026-09-03 |
| `CreatorInterface.add_text` | Modulpfad `ezdxf/graphicsfactory.py` (`inspect.signature`) | `add_text(self, text: str, *, height: Optional[float]=None, rotation: Optional[float]=None, dxfattribs=None) -> Text` | 2026-09-03 |
| `CreatorInterface.add_mtext` | Modulpfad `ezdxf/graphicsfactory.py` (`inspect.signature`) | `add_mtext(self, text: str, dxfattribs=None) -> MText` | 2026-09-03 |
| `CreatorInterface.add_linear_dim` | Modulpfad `ezdxf/graphicsfactory.py` (`inspect.signature`) | `add_linear_dim(self, base: UVec, p1: UVec, p2: UVec, location: Optional[UVec]=None, text: str='<>', angle: float=0, text_rotation: Optional[float]=None, dimstyle: str='EZDXF', override: Optional[dict]=None, dxfattribs=None) -> DimStyleOverride` | 2026-09-03 |
| `CreatorInterface.add_blockref` | Modulpfad `ezdxf/graphicsfactory.py` (`inspect.signature`) | `add_blockref(self, name: str, insert: UVec, dxfattribs=None) -> Insert` | 2026-09-03 |
| `ezdxf.entities.Insert.virtual_entities` | Modulpfad `ezdxf/entities/insert.py` (`inspect.signature`) | `virtual_entities(self, *, skipped_entity_callback=None, redraw_order=False) -> Iterator[DXFGraphic]` | 2026-09-03 |
| `ezdxf.entities.Insert.explode` | Modulpfad `ezdxf/entities/insert.py` (`inspect.signature`) | `explode(self, target_layout: Optional[BaseLayout]=None, *, redraw_order=False) -> EntityQuery` | 2026-09-03 |
| `ezdxf.entities.Dimension.get_measurement` | Modulpfad `ezdxf/entities/dimension.py` (`inspect.signature`) | `get_measurement(self) -> Union[float, Vec3]` | 2026-09-03 |
| `ezdxf.entities.Dimension.dxf.text` (Text-Override) | Verifiziert im Probe-Skript (`ezdxf.readfile` nach `add_linear_dim`+`render()`) | Default `'<>'` (= automatischer Messwert); jeder andere String überschreibt die Anzeige | 2026-09-03 |
| `ezdxf.entities.LWPolyline.get_points` | Modulpfad `ezdxf/entities/lwpolyline.py` (`inspect.signature`) | `get_points(self, format: str='xyseb') -> list[Sequence[float]]` (x, y, start_width, end_width, bulge) | 2026-09-03 |
| `ezdxf.entities.LWPolyline.vertices` | Modulpfad `ezdxf/entities/lwpolyline.py` (`inspect.signature`) | `vertices(self) -> Iterator[tuple[float, float]]` | 2026-09-03 |
| `ezdxf.bbox.extents` | Modulpfad `ezdxf/bbox.py` (`inspect.signature`) | `extents(entities: Iterable[DXFEntity], *, fast=False, cache: Optional[Cache]=None) -> BoundingBox` | 2026-09-03 |
| `ezdxf.units` (Konstanten/Decoder) | Modulpfad `ezdxf/units.py` (interaktiv geprüft) | `units.M == 6`, `units.MM == 4`, `units.decode(6) == 'm'` | 2026-09-03 |
| `ezdxf.addons.odafc.readfile` | https://ezdxf.readthedocs.io/en/stable/addons/odafc.html (offizielle Doku) + Modulpfad `ezdxf/addons/odafc.py` (`inspect.signature`) | `readfile(filename: str \| os.PathLike, version: Optional[str]=None, *, audit: bool=False) -> Drawing` | 2026-09-03 |
| `ezdxf.addons.odafc.export_dwg` | https://ezdxf.readthedocs.io/en/stable/addons/odafc.html + Modulpfad `ezdxf/addons/odafc.py` (`inspect.signature`) | `export_dwg(doc: Drawing, filename: str \| os.PathLike, version: Optional[str]=None, *, audit: bool=False, replace: bool=False) -> None` | 2026-09-03 |
| `ezdxf.addons.odafc.is_installed` | Modulpfad `ezdxf/addons/odafc.py` (`inspect.getsource`) | prüft `platform.system()`; unter Linux/Mac `shutil.which("ODAFileConverter")` oder konfigurierten Pfad, unter Windows `os.path.exists(get_win_exec_path())` | 2026-09-03 |
| `ezdxf.addons.odafc.get_win_exec_path` / `get_unix_exec_path` | Modulpfad `ezdxf/addons/odafc.py` (`inspect.getsource`) | liest `ezdxf.options.get("odafc-addon", "win_exec_path"/"unix_exec_path")`; Default Windows-Pfad `C:\Program Files\ODA\ODAFileConverter\ODAFileConverter.exe` | 2026-09-03 |
| ODA File Converter – unterstützte Plattformen/Versionen | https://ezdxf.readthedocs.io/en/stable/addons/odafc.html | Windows XP/7+, Linux (RPM/DEB 32/64-bit), macOS; DWG-Versionen R12…R2018 (AC1009…AC1032) | 2026-09-03 |
| `ezdxf.addons.drawing.matplotlib.MatplotlibBackend.__init__` | Modulpfad `ezdxf/addons/drawing/matplotlib.py` (`inspect.signature`) | `__init__(self, ax: plt.Axes, *, adjust_figure: bool=True)` | 2026-09-03 |
| `ezdxf.addons.drawing.RenderContext.__init__` | Modulpfad `ezdxf/addons/drawing/properties.py` (`inspect.signature`) | `__init__(self, doc: Optional[Drawing]=None, *, ctb: str \| CTB='', export_mode: bool=False)` | 2026-09-03 |
| `ezdxf.addons.drawing.Frontend.__init__` / `.draw_layout` | Modulpfad `ezdxf/addons/drawing/frontend.py` (`inspect.signature`) | `Frontend(ctx: RenderContext, out: BackendInterface, config: Configuration=..., bbox_cache=None)`; `draw_layout(self, layout: Layout, finalize: bool=True, *, filter_func=None, layout_properties=None) -> None` | 2026-09-03 |
| `ezdxf.addons.drawing.matplotlib.qsave` | Modulpfad `ezdxf/addons/drawing/matplotlib.py` (`inspect.signature` + `inspect.getsource`) | `qsave(layout: Layout, filename: Union[str,PathLike], *, bg=None, fg=None, dpi: int=300, backend: str='agg', config=None, filter_func=None, size_inches=None) -> None` | 2026-09-03 |
| `ezdxf.addons.drawing.config.TextPolicy` | Modulpfad `ezdxf/addons/drawing/config.py` (`inspect`, Enum-Werte gelesen) | `FILLING (default) \| OUTLINE \| REPLACE_RECT \| REPLACE_FILL \| IGNORE` – keine Option erzeugt echten PDF-Text | 2026-09-03 |
| `ezdxf.addons.drawing.matplotlib.MatplotlibBackend.draw_filled_paths` | Modulpfad `ezdxf/addons/drawing/matplotlib.py` (`inspect.getsource`) | zeichnet `matplotlib.patches.PathPatch(..., fill=True)`; kein `draw_text`-Backend-Callback vorhanden → Text wird immer als Pfad/Fläche gerendert | 2026-09-03 |
| Probe-Skript: DXF→PDF→pymupdf Roundtrip | eigener Test `/tmp/.../scratchpad/extract_probe.py` (dieser Session) | bestätigt: `get_drawings()` liefert Linien (`type 's'`, `items=[('l', Point, Point)]`) korrekt; `get_text("dict")` liefert **0 Blöcke**, weil TEXT-Entität als Fläche gerendert wurde | 2026-09-03 |
| `fitz.Page.get_drawings` | Modulpfad `pymupdf`/`fitz` (installiert, `inspect.signature` + Docstring) | `get_drawings(self, extended: bool=False) -> list`; Doc: "Retrieve vector graphics." Items je nach Typ `l` (Line), `c` (Bezier-Kurve), `re` (Rechteck), `qu` (Quad) | 2026-09-03 |
| `fitz.Page.get_text` | Modulpfad `pymupdf` (`inspect.signature`) | `get_text(self, *args, **kwargs)`; verifiziert per Probe: `get_text("dict")["blocks"]` mit `type==0` (Text) enthält `lines[].spans[]` mit `text`, `bbox` | 2026-09-03 |
| `fitz.Page.get_pixmap` | Modulpfad `pymupdf` (`inspect.signature`) | `get_pixmap(page, *, matrix=IdentityMatrix, dpi=None, colorspace=None, clip=None, alpha=False, annots=True) -> Pixmap` | 2026-09-03 |
| `fitz.Matrix` | Modulpfad `pymupdf` (`inspect.signature`) | `__init__(self, *args, a=None, b=None, c=None, d=None, e=None, f=None)` | 2026-09-03 |
| `cv2.HoughLinesP` | Modulpfad `cv2` (installiert, Docstring via `help()`) | `HoughLinesP(image, rho, theta, threshold[, lines[, minLineLength[, maxLineGap]]]) -> lines`; Parameter dokumentiert (Bild 8-bit binär, `rho`/`theta`-Auflösung, `threshold`, `minLineLength`, `maxLineGap`) | 2026-09-03 |
| `cv2.findContours` | Modulpfad `cv2` (Docstring) | `findContours(image, mode, method[, contours[, hierarchy[, offset]]]) -> contours, hierarchy`; ab OpenCV 4.14 bei `RETR_LIST` ohne Hierarchie paralleler TRUCO-Algorithmus, sonst Suzuki85 | 2026-09-03 |
| `cv2.morphologyEx` | Modulpfad `cv2` (Docstring) | `morphologyEx(src, op, kernel[, dst[, anchor[, iterations[, borderType[, borderValue]]]]]) -> dst` | 2026-09-03 |
| `shapely.geometry.LineString.buffer` | Modulpfad `shapely` (installiert, `inspect.signature`) | `buffer(self, distance, quad_segs=16, cap_style='round', join_style='round', mitre_limit=5.0, single_sided=False, **kwargs)` | 2026-09-03 |
| `shapely.ops.unary_union` | Modulpfad `shapely/ops.py` (`inspect.signature`) | `unary_union(geoms)` | 2026-09-03 |
| `shapely.ops.polygonize` | Modulpfad `shapely/ops.py` (`inspect.signature`) | `polygonize(lines)` | 2026-09-03 |
| `shapely.geometry.Polygon` | Modulpfad `shapely` (`inspect.signature`, generischer `__init__(self, /, *args, **kwargs)`; Konstruktor akzeptiert `shell, holes=None` laut Shapely-Doku) | `Polygon(shell, holes=None)` | 2026-09-03 |
| `shapely.contains` | Modulpfad `shapely` (`inspect.signature`) | `contains(a, b, **kwargs) -> bool`/Array | 2026-09-03 |
| SIA 2014 / CAD-Layerstruktur (Architekt) | https://shop.sia.ch/normenwerk/architekt/2014_2017_d/D/Product ; https://media.bs.ch/original_file/bfdb4a6d5efde9cf350dcb0010a782b08625bd4a/cad-richtlinie-sa-version-4-3-okt24-2-3410.pdf ; https://www.cadexchange.ch/produkteliste/cp0002-layerstruktur-architektur/ | SIA-Merkblatt 2014 „CAD-Datenaustausch – Layerstruktur und Layerschlüssel"; Layercodierung an eBKP-H (CRB) gekoppelt; kantonale Hochbauämter (BS, SO, ZG) veröffentlichen eigene konkretisierende CAD-Richtlinien mit Layerlisten | 2026-09-03 |
| ODA File Converter – Formate | https://ezdxf.readthedocs.io/en/stable/addons/odafc.html | konvertiert zwischen DWG-/DXB-/DXF-Versionen | 2026-09-03 |
| CubiCasa5K Datensatz | Web-Recherche (arxiv/ResearchGate, u. a. „Raster-to-Vector: Revisiting Floorplan Transformation" https://www.researchgate.net/publication/322059565 , https://art-programmer.github.io/floorplan-transformation.html , „Deep Floor Plan Recognition" https://arxiv.org/pdf/1908.11025 ) | Raster-Grundriss-Datensatz mit 4199/399/399 Train/Val/Test-Bildern, 11 Klassen annotiert; Referenz-Benchmark für Raster→Vektor-ML | 2026-09-03 |
| WiseBIM / Plans2BIM | https://wisebim.fr/software/plans2bim/ ; https://www.buildingsmart.org/wp-content/uploads/2022/10/428-TECHNOLOGY-Plans2BIM.pdf ; https://architosh.com/2024/05/wisebim-ai-from-2d-plans-to-revit-bim-models/ | Cloud-SaaS, nimmt PDF/PNG/JPEG (Raster) und DWG/DXF (Vektor) entgegen, erkennt Wände/Fenster/Türen/Decken per KI, Output: Revit-BIM, IFC, DXF, CSV/XLSX-Mengen; Verarbeitungszeit 10s–3min | 2026-09-03 |
