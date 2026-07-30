#!/usr/bin/env python3
"""Validate the manuscript-to-code audit and every declared public target."""

from pathlib import Path
import csv

ROOT = Path(__file__).resolve().parents[1]
audit_path = ROOT / "manifests" / "manuscript_method_audit.tsv"
with audit_path.open(encoding="utf-8") as handle:
    rows = list(csv.DictReader(handle, delimiter="\t"))

required_columns = {
    "scope",
    "method",
    "manuscript specification",
    "public implementation",
    "status",
    "audit note",
}
if not rows or set(rows[0]) != required_columns:
    raise SystemExit("Manuscript method audit has an invalid schema")
if len(rows) < 50:
    raise SystemExit("Manuscript method audit is unexpectedly incomplete")

keys = [(row["scope"], row["method"]) for row in rows]
if len(keys) != len(set(keys)):
    raise SystemExit("Duplicate scope-method rows in manuscript method audit")

allowed_status = {
    "PASS",
    "PASS_RETAINED_SENSITIVITY",
    "METHOD_TEXT_MISMATCH_RESOLVED",
    "DOCUMENTED_EXTERNAL",
    "EXPLORATORY_NOT_FINAL",
}
for row in rows:
    if row["status"] not in allowed_status:
        raise SystemExit(
            f"Unsupported audit status for {row['method']}: {row['status']}"
        )
    for target in row["public implementation"].split(";"):
        path = ROOT / target.strip()
        if not path.exists():
            raise SystemExit(
                f"Missing audit target for {row['method']}: {target.strip()}"
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
    raise SystemExit(f"Audit omits required methods: {sorted(missing)}")

print(f"PASS: {len(rows)} manuscript and scope-control methods are audited")
