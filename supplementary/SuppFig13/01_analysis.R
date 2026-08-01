#!/usr/bin/env Rscript

# SuppFig13: Robustness of malignant epithelial subcluster assignments and functional programs under alternative inferCNV reference selection
# The source workflow for each panel is recorded in panel_plan. This script
# checks the exported columns and writes the tables used for figure assembly.

source(file.path("core", "R", "cli.R"))
source(file.path("core", "R", "figure_assembly.R"))
opts <- parse_common_args()
set.seed(opts$seed)

panel_plan <- list(
  list(
    panel = "A",
    title = "Original adjacent-epithelial-reference inferCNV heatmap",
    workflow = "workflows/single_cell/02a_infercnv_adjacent_epithelial_reference.R",
    operation = "select",
    input = "SuppFig13_A.tsv",
    required = c("cell_id", "chromosome", "position", "cnv_value"),
    output = "panel_A_data.tsv"
  ),
  list(
    panel = "B",
    title = "Within-sample non-epithelial-reference inferCNV heatmap",
    workflow = "workflows/single_cell/02_infercnv_non_epi_reference.R",
    operation = "select",
    input = "SuppFig13_B.tsv",
    required = c("cell_id", "chromosome", "position", "cnv_value"),
    output = "panel_B_data.tsv"
  ),
  list(
    panel = "C",
    title = "Cell-level CNV burden percentile concordance",
    workflow = "workflows/single_cell/02b_infercnv_reference_robustness.R",
    operation = "select",
    input = "SuppFig13_C.tsv",
    required = c("cell_id", "sample", "primary_percentile", "sensitivity_percentile"),
    output = "panel_C_data.tsv"
  ),
  list(
    panel = "D",
    title = "Patient-specific CNV burden rank correlations",
    workflow = "workflows/single_cell/02b_infercnv_reference_robustness.R",
    operation = "select",
    input = "SuppFig13_D.tsv",
    required = c("sample", "n_cells", "spearman_rho"),
    output = "panel_D_data.tsv"
  ),
  list(
    panel = "E",
    title = "Original and revised malignant-subcluster UMAPs",
    workflow = "workflows/single_cell/02b_infercnv_reference_robustness.R",
    operation = "select",
    input = "SuppFig13_E.tsv",
    required = c("cell_id", "UMAP_1", "UMAP_2", "analysis", "cell_state"),
    output = "panel_E_data.tsv"
  ),
  list(
    panel = "F",
    title = "Overlap of malignant cells under both references",
    workflow = "workflows/single_cell/02b_infercnv_reference_robustness.R",
    operation = "select",
    input = "SuppFig13_F.tsv",
    required = c("primary_malignant", "sensitivity_malignant", "count"),
    output = "panel_F_data.tsv"
  ),
  list(
    panel = "G",
    title = "Malignant-subcluster marker-profile concordance",
    workflow = "workflows/single_cell/02b_infercnv_reference_robustness.R",
    operation = "select",
    input = "SuppFig13_G.tsv",
    required = c("primary_cluster", "sensitivity_cluster", "spearman_rho"),
    output = "panel_G_data.tsv"
  ),
  list(
    panel = "H",
    title = "Cancer_c0 and Cancer_c3 Hallmark NES concordance",
    workflow = "workflows/single_cell/02b_infercnv_reference_robustness.R",
    operation = "select",
    input = "SuppFig13_H.tsv",
    required = c("cell_state", "pathway", "primary_NES", "sensitivity_NES"),
    output = "panel_H_data.tsv"
  )
)

audit <- run_figure_analysis("SuppFig13", panel_plan, opts)
write_run_metadata(
  opts$output_dir,
  "SuppFig13_analysis",
  opts,
  list(
    computational_panels = sum(audit$status == "written"),
    documented_noncomputational_panels =
      sum(audit$status == "documented_noncomputational_panel")
  )
)
