"""Plan2Allplan PythonPart package (Allplan 2026).

The .pyp references ``Plan2Allplan.py``; because this folder carries an
``__init__.py`` Python resolves it as the package instead (documented layout,
see https://pythonparts.allplan.com/2026/manual/key_components/ and the
SlabReinforcement project of the same author).
"""

from .dummy import check_allplan_version, create_element

__all__ = ["check_allplan_version", "create_element"]
