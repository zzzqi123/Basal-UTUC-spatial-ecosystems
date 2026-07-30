#!/usr/bin/env python3
"""Enforce manuscript-locked cell2location and scPagwas parameters."""

from pathlib import Path
import yaml

ROOT = Path(__file__).resolve().parents[1]
with (ROOT / "config" / "parameters.yaml").open(encoding="utf-8") as handle:
    cfg = yaml.safe_load(handle)

c2l = cfg["cell2location"]
expected_c2l = {
    "reference_max_epochs": 250,
    "n_cells_per_location": 30,
    "detection_alpha": 20,
    "spatial_max_epochs": 50000,
    "batch_size": None,
    "train_size": 1,
    "neighbors": 15,
    "leiden_resolution": 0.3,
}
for key, value in expected_c2l.items():
    if c2l.get(key) != value:
        raise SystemExit(f"cell2location mismatch: {key}={c2l.get(key)!r}, expected {value!r}")

scpagwas = cfg["scPagwas"]
expected_scpagwas = {
    "entrypoint": "scPagwas_main",
    "iterations_celltype": 200,
    "iterations_singlecell": 100,
    "top_genes": 1000,
    "multiple_testing": "BH",
}
for key, value in expected_scpagwas.items():
    if scpagwas.get(key) != value:
        raise SystemExit(f"scPagwas mismatch: {key}={scpagwas.get(key)!r}, expected {value!r}")

spatial_script = (
    ROOT / "methods" / "cell2location" / "02_spatial_mapping.py"
).read_text(encoding="utf-8")
if 'cfg["spatial_max_epochs"]' not in spatial_script:
    raise SystemExit("Spatial mapping does not consume the locked 50,000-epoch parameter")

for path in list((ROOT / "config").rglob("*")) + list((ROOT / "methods").rglob("*")):
    if not path.is_file() or ".git" in path.parts:
        continue
    if path.suffix.lower() not in {".py", ".r", ".yaml", ".yml", ".md", ".tsv"}:
        continue
    text = path.read_text(encoding="utf-8", errors="ignore")
    if "max_epochs=20000" in text or "max_epochs = 20000" in text:
        raise SystemExit(f"Historical 20,000-epoch value found in {path.relative_to(ROOT)}")

print("PASS: manuscript-locked parameters are consistent")
