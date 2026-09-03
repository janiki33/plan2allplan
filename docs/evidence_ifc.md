# IFC-Quellenprotokoll (evidence_ifc.md)

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

## Offene / widersprüchliche Punkte (nicht in Tabelle, da keine belastbare Quelle gefunden)

- Keine offizielle Allplan-Dokumentation gefunden, die bestätigt, ob Allplan 2026 beim
  **Import** zwingend eine Axis-Representation (Model/Axis oder Plan/Axis Subcontext)
  verlangt, um eine Wand als natives Wand-Objekt (statt Proxy) zu erkennen, oder ob eine
  reine Body/SweptSolid-Repräsentation ausreicht. Die zitierte Allplan-Hilfeseite
  beschreibt nur die Mapping-Regeln (Klassenname → Allplan-Objekttyp), nicht die
  geometrischen Mindestanforderungen.
- Keine Quelle (Allplan-Hilfe oder Forum) explizit für Allplan **2026** gefunden; die
  zitierte Hilfeseite ist für 2023-0. Funktionsumfang der IFC-Importfilter wird als
  stabil angenommen, aber nicht für 2026 verifiziert.
