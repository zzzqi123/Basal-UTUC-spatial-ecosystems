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

required_workflows = (
    "workflows/single_cell/01b_annotation_and_markers.R",
    "workflows/single_cell/01c_lineage_subclustering.R",
    "workflows/single_cell/02a_infercnv_adjacent_epithelial_reference.R",
    "workflows/single_cell/03_trajectory_analysis.R",
    "workflows/single_cell/03b_monocle3_robustness.R",
    "workflows/single_cell/08_marker_visualization.R",
    "workflows/single_cell/09_roe_composition.R",
    "workflows/spatial/07_cellstate_correlation_colocalization.R",
    "workflows/spatial/08_spagene_lr_colocalization.R",
    "workflows/spatial/09_spacet_gene_set_scores.R",
    "workflows/spatial/10_visiumhd_niche_colocalization.R",
    "workflows/spatial/11a_prepare_external_visium_scores.R",
    "workflows/spatial/11_external_visium_basal_axis.R",
    "workflows/spatial/12_geomx_roi_validation.R",
    "workflows/communication/03_cellchat_spatial.R",
    "workflows/genetics/03_phewas_mr_spp1.R",
    "workflows/bulk_clinical_validation/00_prepare_bulk_scores.R",
)
for relative in required_workflows:
    if not (ROOT / relative).is_file():
        raise SystemExit(f"Required workflow is missing: {relative}")

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
