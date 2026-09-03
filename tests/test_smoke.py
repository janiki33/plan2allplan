"""Stage 0 smoke tests: environment and architectural rule (no Allplan imports in core/)."""

from __future__ import annotations

import importlib
import pathlib
import re

import pytest

ROOT = pathlib.Path(__file__).resolve().parents[1]

REQUIRED_LIBS = ["pydantic", "ezdxf", "fitz", "ifcopenshell", "shapely", "numpy", "cv2"]


@pytest.mark.parametrize("lib", REQUIRED_LIBS)
def test_required_library_importable(lib: str) -> None:
    importlib.import_module(lib)


def test_core_has_no_allplan_imports() -> None:
    """core/ must stay testable without Allplan (task rule 2.4)."""
    pattern = re.compile(r"^\s*(import|from)\s+(NemAll_|Allplan|BuildingElement|BaseScriptObject)", re.M)
    offenders = [p for p in (ROOT / "core").rglob("*.py") if pattern.search(p.read_text(encoding="utf-8"))]
    assert offenders == [], f"Allplan imports found in core/: {offenders}"


def test_project_layout_exists() -> None:
    for rel in ["core/schema", "core/extract", "core/interpret", "core/validate", "core/export_ifc",
                "allplan_adapter", "tests/fixtures", "tests/allplan_manual", "docs"]:
        assert (ROOT / rel).is_dir(), rel
