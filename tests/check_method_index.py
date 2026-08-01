#!/usr/bin/env python3
"""Validate the manuscript method index and its declared script paths."""

from pathlib import Path
import csv

ROOT = Path(__file__).resolve().parents[1]
index_path = ROOT / "manifests" / "method_index.tsv"
with index_path.open(encoding="utf-8") as handle:
    rows = list(csv.DictReader(handle, delimiter="\t"))

required_columns = {
    "analysis layer",
    "method",
    "manuscript specification",
    "script",
    "status",
    "note",
}
if not rows or set(rows[0]) != required_columns:
    raise SystemExit("Method index has an invalid schema")
if len(rows) < 50:
    raise SystemExit("Method index is unexpectedly incomplete")

keys = [(row["analysis layer"], row["method"]) for row in rows]
if len(keys) != len(set(keys)):
    raise SystemExit("Duplicate analysis-layer and method rows in method index")

allowed_status = {
    "included",
    "sensitivity",
    "included_with_note",
    "methods_update",
    "external_step",
}
for row in rows:
    if row["status"] not in allowed_status:
        raise SystemExit(
            f"Unsupported method-index status for {row['method']}: {row['status']}"
        )
    for target in row["script"].split(";"):
        path = ROOT / target.strip()
        if not path.exists():
            raise SystemExit(
                f"Missing script target for {row['method']}: {target.strip()}"
            )

required_methods = {
    "Lineage subclustering",
    "inferCNV primary reference",
    "Primary pseudotime",
    "Trajectory robustness",
    "Marker heatmaps and enrichment",
    "Marker density",
    "Relative observed-to-expected composition",
    "Ordinal cell-state co-localization",
    "SpaGene ligand-receptor co-localization",
    "SpaCET spatial pathway scoring",
    "Spatial CellChat",
    "CIBERSORTx deconvolution",
    "Visium HD deconvolution",
    "External Visium deconvolution",
    "GeoMx ROI validation",
    "SPP1 PheW-MR",
    "ESTIMATE scores",
    "BASE47 GSVA",
    "Survival and ROC",
}
observed_methods = {row["method"] for row in rows}
missing = required_methods - observed_methods
if missing:
    raise SystemExit(f"Method index omits required methods: {sorted(missing)}")

print(f"PASS: {len(rows)} manuscript methods are indexed")
