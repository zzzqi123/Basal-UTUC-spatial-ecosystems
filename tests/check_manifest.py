#!/usr/bin/env python3
"""Validate panel-level main and supplementary figure coverage."""

from pathlib import Path
import csv

ROOT = Path(__file__).resolve().parents[1]
manifest = ROOT / "manifests" / "figure_manifest.tsv"
required_files = {
    "README.md",
    "01_analysis.R",
    "02_plot.R",
    "config.yaml",
    "expected_outputs.txt",
}

with manifest.open(encoding="utf-8") as handle:
    rows = list(csv.DictReader(handle, delimiter="\t"))

expected_ids = {f"Fig{i:02d}" for i in range(1, 12)}
expected_ids |= {f"SuppFig{i:02d}" for i in range(1, 14)}
observed_ids = {row["figure"] for row in rows}
if observed_ids != expected_ids:
    raise SystemExit(
        f"Figure manifest mismatch: missing={sorted(expected_ids-observed_ids)}, "
        f"extra={sorted(observed_ids-expected_ids)}"
    )

keys = [(row["figure"], row["panel"]) for row in rows]
if len(keys) != len(set(keys)):
    raise SystemExit("Figure manifest contains duplicate figure-panel rows")
if len(rows) < 100:
    raise SystemExit("Figure manifest is not panel-level or is unexpectedly incomplete")

for row in rows:
    module = ROOT / row["module"]
    present = {path.name for path in module.iterdir()}
    missing = required_files.difference(present)
    if missing:
        raise SystemExit(
            f"{row['figure']} missing module files: {sorted(missing)}"
        )
    for key in ("analysis_script", "plot_script"):
        if not (ROOT / row[key]).is_file():
            raise SystemExit(f"{row['figure']} {row['panel']} missing {key}")
    if not row["source_workflow"] or not row["panel_type"]:
        raise SystemExit(f"{row['figure']} {row['panel']} lacks method mapping")

print(
    f"PASS: {len(rows)} panels cover Fig01-Fig11 and "
    "SuppFig01-SuppFig13"
)
