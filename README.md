# plan2allplan

Architektenpläne (Grundrisse + Schnitte, DWG/PDF) → nativ editierbares Allplan-2026-Rohbaumodell
(Wände, Stützen, Decken, Brüstungen/Stürze, Aussparungen, Liftgruben, Dämmung/Magerbeton) per
PythonPart, alternativ IFC4-Export. Höhen werden an die Ebenen der Allplan-Bauwerksstruktur
angebunden. Fehlende oder widersprüchliche Informationen führen zu Rückfragen, nicht zu Annahmen.

Status: **Etappe 0 (Recherche & Fundament)** – siehe `docs/`.

```
core/             reine Python-Logik (keine Allplan-Importe)
allplan_adapter/  PythonPart (Library/*.pyp, PythonPartsScripts/*.py)
tests/            pytest; tests/allplan_manual/ = manuelle Protokolle für Allplan
docs/             Research-Berichte, api_evidence.md, ADRs, Reviews
sync_allplan.ps1  Zwei-Wege-Abgleich Repo <-> Allplan-Benutzerordner
```

Einrichtung: `pip install -r requirements.txt && python -m pytest`
