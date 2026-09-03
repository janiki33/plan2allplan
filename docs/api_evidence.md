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
| `check_allplan_version(build_ele, version)` | EX/PythonPartsExampleScripts/ToolsAndStartExamples/HelloWorld.py:17 | `def check_allplan_version(_build_ele: BuildingElement, _version: str)` → bool | 2026-09-03 |
| `create_element(build_ele, doc)` | EX/PythonPartsExampleScripts/ToolsAndStartExamples/HelloWorld.py:33 | `def create_element(build_ele: BuildingElement, _doc: AllplanElementAdapter.DocumentAdapter)` → `(model_elem_list, handle_list)` | 2026-09-03 |
| `BuildingElement` | EX/PythonPartsExampleScripts/ToolsAndStartExamples/HelloWorld.py:11 | `from BuildingElement import BuildingElement`; Parameterzugriff `build_ele.Length.value` | 2026-09-03 |
| `NemAll_Python_Geometry.Line2D` | EX/…/HelloWorld.py:51 | `AllplanGeo.Line2D(0, 0, length, 0)` | 2026-09-03 |
| `NemAll_Python_AllplanSettings.AllplanGlobalSettings.GetCurrentCommonProperties` | EX/…/HelloWorld.py:56 | `AllplanSettings.AllplanGlobalSettings.GetCurrentCommonProperties()` | 2026-09-03 |
| `NemAll_Python_BasisElements.ModelElement2D` | EX/…/HelloWorld.py:61 | `AllplanBasisElements.ModelElement2D(common_props, line)` | 2026-09-03 |
| `NemAll_Python_IFW_ElementAdapter.DocumentAdapter` | EX/…/HelloWorld.py:34 | Typ des `doc`-Arguments von `create_element` | 2026-09-03 |
| `.pyp`-Struktur (`<Script><Name>`, `<Page>`, `<Parameter>` mit `ValueType` Length) | EX/Library/Examples/PythonParts/ToolsAndStartExamples/HelloWorld.pyp | XML nach `https://pythonparts.allplan.com/2026/schemas/PythonPart.xsd` | 2026-09-03 |
| Paket-Layout (Ordner mit `__init__.py` statt `<Name>.py`) | DOC/manual/key_components/ (File locations); janiki33/allplan-slab-reinforcement PythonPartsScripts/SlabReinforcement/__init__.py | `.pyp` `<Name>Plan2Allplan.py</Name>` → Paket `PythonPartsScripts/Plan2Allplan/__init__.py` exportiert `check_allplan_version`, `create_element` | 2026-09-03 |

## Etappe 0 – Recherche-Belege

Die Belege der drei Research-Agenten werden nach Abschluss der Recherche hier eingegliedert
(Abschnitte «Allplan», «IFC», «Extraktion»).
