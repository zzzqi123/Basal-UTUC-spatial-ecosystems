#!/usr/bin/env python3
"""Validate figure coverage and required module interfaces."""

from pathlib import Path
import csv

ROOT = Path(__file__).resolve().parents[1]
manifest = ROOT / "manifests" / "figure_manifest.tsv"
required = {
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

for row in rows:
    module = ROOT / row["module"]
    missing = required.difference(path.name for path in module.iterdir())
    if missing:
        raise SystemExit(f"{row['figure']} missing module files: {sorted(missing)}")
    for key in ("analysis_script", "plot_script"):
        if not (ROOT / row[key]).is_file():
            raise SystemExit(f"{row['figure']} missing {key}: {row[key]}")
    if not row["panels"] or not row["primary_methods"]:
        raise SystemExit(f"{row['figure']} lacks panels or methods")

print(f"PASS: {len(rows)} figure modules cover Fig01-Fig11 and SuppFig01-SuppFig13")

