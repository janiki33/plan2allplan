"""Stage 0 dummy PythonPart: draws one 2D line so the sync round trip can be verified.

Derived line by line from the official example
PythonPartsExampleScripts/ToolsAndStartExamples/HelloWorld.py (branch 2026).
Every API symbol used here is listed in docs/api_evidence.md.
"""

import NemAll_Python_AllplanSettings as AllplanSettings
import NemAll_Python_BasisElements as AllplanBasisElements
import NemAll_Python_Geometry as AllplanGeo
import NemAll_Python_IFW_ElementAdapter as AllplanElementAdapter

from BuildingElement import BuildingElement

print("Load Plan2Allplan dummy (stage 0)")


def check_allplan_version(_build_ele: BuildingElement, _version: str) -> bool:
    """Accept every Allplan version (same as HelloWorld example)."""
    return True


def create_element(build_ele: BuildingElement,
                   _doc: AllplanElementAdapter.DocumentAdapter):
    """Create one horizontal 2D line of the length given in the palette."""
    length = build_ele.Length.value
    line = AllplanGeo.Line2D(0, 0, length, 0)
    common_props = AllplanSettings.AllplanGlobalSettings.GetCurrentCommonProperties()
    model_elem_list = [AllplanBasisElements.ModelElement2D(common_props, line)]
    handle_list = []
    return (model_elem_list, handle_list)
