#!/usr/bin/env python3
"""Check the cell2location and scPagwas parameters reported in Methods."""

from pathlib import Path
import yaml

ROOT = Path(__file__).resolve().parents[1]
with (ROOT / "config" / "parameters.yaml").open(encoding="utf-8") as handle:
    cfg = yaml.safe_load(handle)

environment_text = (ROOT / "environment.yml").read_text(encoding="utf-8")
if "python=3.10.11" not in environment_text or "r-base=4.3.1" not in environment_text:
    raise SystemExit("R/Python versions do not match the manuscript Methods")

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

single_cell = cfg["single_cell"]
expected_single_cell = {
    "min_features": 300,
    "max_features": 6000,
    "max_mito_percent": 30,
    "max_hemoglobin_percent": 3,
    "normalization_scale_factor": 10000,
    "highly_variable_genes": 2000,
    "pca_dimensions": 20,
    "infercnv_cutoff": 0.1,
    "cnv_score_threshold": 0.0005,
    "cnv_correlation_threshold": 0.2,
    "monocle2_min_mean_expression": 0.1,
    "monocle2_min_cells": 10,
    "monocle2_top_ordering_genes": 1000,
    "monocle2_reduction": "DDRTree",
}
for key, value in expected_single_cell.items():
    if single_cell.get(key) != value:
        raise SystemExit(
            f"Single-cell mismatch: {key}={single_cell.get(key)!r}, expected {value!r}"
        )

sctenifoldknk = cfg["sctenifoldknk"]
expected_sctenifoldknk = {
    "package_version": "1.0.3",
    "target_gene": "SPP1",
    "malignant_states": ["Cancer_c0", "Cancer_c1", "Cancer_c2", "Cancer_c3", "Cancer_c4"],
    "network_genes": 1000,
    "nc_nNet": 5,
    "nc_nCells": 1000,
    "nc_nComp": 5,
    "td_K": 3,
    "ma_nDim": 2,
}
for key, value in expected_sctenifoldknk.items():
    if sctenifoldknk.get(key) != value:
        raise SystemExit(
            f"scTenifoldKnk mismatch: {key}={sctenifoldknk.get(key)!r}, "
            f"expected {value!r}"
        )

cibersortx = cfg["cibersortx"]
expected_cibersortx = {
    "annotation_column": "second_celltype_byhand",
    "reference_assay": "RNA",
    "max_cells_per_state": 300,
    "bulk_gene_column": "GeneSymbol",
    "bulk_input_scale": "VST",
    "expected_bulk_samples": 158,
    "relative_sum_tolerance": 0.001,
    "execution_mode": "web_service_default_relative_fractions",
}
for key, value in expected_cibersortx.items():
    if cibersortx.get(key) != value:
        raise SystemExit(
            f"CIBERSORTx mismatch: {key}={cibersortx.get(key)!r}, "
            f"expected {value!r}"
        )

sctenifold_script = (
    ROOT / "workflows" / "single_cell" / "10_spp1_virtual_knockout.R"
).read_text(encoding="utf-8")
for forbidden in ('gKO = "FAP"', 'targets <- c("SPP1", "FAP")', "utuc_tme_cells"):
    if forbidden in sctenifold_script:
        raise SystemExit(f"Obsolete TME/FAP perturbation remains: {forbidden}")

spatial_cellchat = cfg["spatial_cellchat"]
expected_spatial_cellchat = {
    "database": "CellChatDB.human",
    "interaction_range_um": 250,
    "scale_distance": 3.65,
    "contact_range_um": 100,
    "min_cells": 10,
}
for key, value in expected_spatial_cellchat.items():
    if spatial_cellchat.get(key) != value:
        raise SystemExit(
            f"Spatial CellChat mismatch: {key}={spatial_cellchat.get(key)!r}, "
            f"expected {value!r}"
        )

rctd = cfg["rctd"]
if rctd.get("gse299573_mode") != "doublet":
    raise SystemExit("GSE299573 must use RCTD doublet mode")
if rctd.get("gse319536_mode") != "full":
    raise SystemExit("GSE319536 must use RCTD full mode")
if cfg["external_spatial_validation"].get("expected_sections") != 22:
    raise SystemExit("GSE319536 must declare the 22-section contract")

phewas = cfg["phewas_mr"]
expected_phewas = {
    "target_gene": "SPP1",
    "instrument_source": "eQTLGen_Phase1",
    "outcome_source": "UK_Biobank_SAIGE_PheWeb",
    "outcome_sample_size": 456348,
    "total_binary_phenotypes": 1403,
    "min_cases_exclusive": 500,
    "expected_eligible_phenotypes": 679,
    "heidi_p_threshold": 0.1,
    "fdr_threshold": 0.05,
    "multiple_testing": "BH",
}
for key, value in expected_phewas.items():
    if phewas.get(key) != value:
        raise SystemExit(
            f"PheW-MR mismatch: {key}={phewas.get(key)!r}, expected {value!r}"
        )

spatial_script = (
    ROOT / "workflows" / "spatial" / "cell2location" / "02_spatial_mapping.py"
).read_text(encoding="utf-8")
if 'cfg["spatial_max_epochs"]' not in spatial_script:
    raise SystemExit("Spatial mapping does not consume the locked 50,000-epoch parameter")

for path in list((ROOT / "config").rglob("*")) + list((ROOT / "workflows").rglob("*")):
    if not path.is_file() or ".git" in path.parts:
        continue
    if path.suffix.lower() not in {".py", ".r", ".yaml", ".yml", ".md", ".tsv"}:
        continue
    text = path.read_text(encoding="utf-8", errors="ignore")
    if "max_epochs=20000" in text or "max_epochs = 20000" in text:
        raise SystemExit(f"Historical 20,000-epoch value found in {path.relative_to(ROOT)}")

print("PASS: reported method parameters are consistent")
