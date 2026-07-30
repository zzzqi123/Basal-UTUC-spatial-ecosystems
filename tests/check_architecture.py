#!/usr/bin/env python3
"""Enforce the four-layer layout and semantic method separation."""

from pathlib import Path
import csv

ROOT = Path(__file__).resolve().parents[1]
for directory in ("core", "workflows", "figures", "supplementary"):
    if not (ROOT / directory).is_dir():
        raise SystemExit(f"Missing top-level layer: {directory}")
for legacy in ("functions", "methods"):
    if (ROOT / legacy).exists():
        raise SystemExit(f"Legacy top-level directory remains: {legacy}")

c2l = ROOT / "workflows" / "spatial" / "cell2location"
if not c2l.is_dir() or len(list(c2l.glob("*.py"))) != 4:
    raise SystemExit("cell2location must contain four scripts under workflows/spatial")
japan = (
    ROOT
    / "workflows"
    / "bulk_clinical_validation"
    / "02_japan_utuc_validation.R"
)
if not japan.is_file():
    raise SystemExit("Japan-UTUC clinical validation is not in bulk_clinical_validation")
for path in (ROOT / "workflows" / "spatial").glob("*japan*"):
    raise SystemExit(f"Japan-UTUC file incorrectly placed in spatial: {path.name}")

with (ROOT / "manifests" / "figure_manifest.tsv").open(encoding="utf-8") as handle:
    rows = list(csv.DictReader(handle, delimiter="\t"))
for row in rows:
    if "Japan-UTUC" in row["title"] and not row["source_workflow"].startswith(
        "workflows/bulk_clinical_validation/"
    ):
        raise SystemExit(
            f"Japan panel mapped outside bulk/clinical: {row['figure']}{row['panel']}"
        )
    if "cell2location" in row["source_workflow"] and not row[
        "source_workflow"
    ].startswith("workflows/spatial/"):
        raise SystemExit(
            f"cell2location mapped outside spatial: {row['figure']}{row['panel']}"
        )

for directory in (ROOT / "figures", ROOT / "supplementary"):
    for script in directory.glob("*/*.R"):
        nonblank = [
            line for line in script.read_text(encoding="utf-8").splitlines()
            if line.strip()
        ]
        if len(nonblank) < 30:
            raise SystemExit(f"Figure script is still a thin wrapper: {script}")

tracked_text = "\n".join(
    path.read_text(encoding="utf-8", errors="ignore")
    for base in ("README.md", "core", "workflows", "figures", "supplementary")
    for path in ([ROOT / base] if (ROOT / base).is_file() else (ROOT / base).rglob("*"))
    if path.is_file() and path.suffix.lower() in {"", ".md", ".r", ".py", ".sh"}
)
if 'file.path("functions"' in tracked_text or "methods/cell2location" in tracked_text:
    raise SystemExit("Legacy functions/methods references remain")

print("PASS: four-layer architecture and method separation are correct")
