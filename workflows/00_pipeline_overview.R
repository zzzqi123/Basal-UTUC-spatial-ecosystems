#!/usr/bin/env Rscript

# Article-level execution map. This file records the intended hand-off between
# workflows without assuming that private cohorts are present in the repository.

pipeline <- data.frame(
  order = seq_len(12),
  branch = c(
    "single_cell", "single_cell", "single_cell", "genetics",
    "spatial", "spatial", "spatial", "communication",
    "communication", "perturbation", "bulk_clinical", "figure_assembly"
  ),
  script = c(
    "workflows/single_cell/01_process_scrna.R",
    "workflows/single_cell/02_infercnv_non_epi_reference.R",
    "workflows/single_cell/03_trajectory_analysis.R",
    "workflows/genetics/01_scpagwas.R",
    "workflows/spatial/cell2location/01_reference_signatures.py",
    "workflows/spatial/cell2location/02_spatial_mapping.py",
    "workflows/spatial/02_multiscale_pair_burden.py",
    "workflows/communication/01_cellchat.R",
    "workflows/communication/02_nichenet_tam_to_mycaf.R",
    "workflows/perturbation/01_spp1_virtual_knockout.R",
    "workflows/bulk_clinical_validation/02_japan_utuc_validation.R",
    "figures/FigXX/01_analysis.R"
  ),
  main_output = c(
    "processed annotated single-cell object",
    "non-epithelial-reference inferCNV result",
    "cell-state pseudotime table",
    "cell-level and cell-type GWAS FDR tables",
    "single-cell reference signatures",
    "spot-by-cell-state posterior abundance",
    "section-level pair burden and spatial O/E tables",
    "global ligand-receptor table",
    "ranked TAM-to-myCAF candidate ligands",
    "malignant-epithelial perturbation result",
    "Japan-UTUC logistic and Cox model tables",
    "panel-specific de-identified tables and vector plots"
  ),
  stringsAsFactors = FALSE
)

if (sys.nframe() == 0L) {
  write.table(
    pipeline,
    file = stdout(),
    sep = "\t",
    quote = FALSE,
    row.names = FALSE
  )
}
