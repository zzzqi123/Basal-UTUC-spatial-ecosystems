#!/usr/bin/env Rscript

# Fig07: External bladder urothelial carcinoma datasets support the SPP1+ TAM-FAP+ myCAF program
# Heavy model fitting is performed by the named workflows. This script exposes
# the exact panel hand-off, validates de-identified table schemas, and writes
# one analysis table per computational panel.

source(file.path("core", "R", "cli.R"))
source(file.path("core", "R", "figure_assembly.R"))
opts <- parse_common_args()
set.seed(opts$seed)

panel_plan <- list(
  list(
    panel = "A",
    title = "Visium HD RCTD embedding",
    workflow = "workflows/spatial/06_external_rctd.R -> workflows/spatial/10_visiumhd_niche_colocalization.R",
    operation = "select",
    input = "Fig07_A.tsv",
    required = c("UMAP_1", "UMAP_2", "cell_type"),
    output = "panel_A_data.tsv"
  ),
  list(
    panel = "B",
    title = "Visium HD inferred cell-type map",
    workflow = "workflows/spatial/06_external_rctd.R -> workflows/spatial/10_visiumhd_niche_colocalization.R",
    operation = "select",
    input = "Fig07_B.tsv",
    required = c("x", "y", "cell_type", "proportion"),
    output = "panel_B_data.tsv"
  ),
  list(
    panel = "C",
    title = "External SPP1 TAM-myCAF score",
    workflow = "workflows/spatial/06_external_rctd.R -> workflows/spatial/10_visiumhd_niche_colocalization.R",
    operation = "select",
    input = "Fig07_C.tsv",
    required = c("x", "y", "pair_score"),
    output = "panel_C_data.tsv"
  ),
  list(
    panel = "D",
    title = "Basal, luminal and component maps",
    workflow = "workflows/spatial/06_external_rctd.R -> workflows/spatial/10_visiumhd_niche_colocalization.R",
    operation = "select",
    input = "Fig07_D.tsv",
    required = c("x", "y", "feature", "value"),
    output = "panel_D_data.tsv"
  ),
  list(
    panel = "E",
    title = "GeoMx component-score correlation",
    workflow = "workflows/spatial/12_geomx_roi_validation.R",
    operation = "select",
    input = "Fig07_E.tsv",
    required = c("spp1_tam_score", "fap_mycaf_score", "region"),
    output = "panel_E_data.tsv"
  ),
  list(
    panel = "F",
    title = "GeoMx cytotoxic-program associations",
    workflow = "workflows/spatial/12_geomx_roi_validation.R",
    operation = "select",
    input = "Fig07_F.tsv",
    required = c("program", "estimate", "FDR"),
    output = "panel_F_data.tsv"
  ),
  list(
    panel = "G",
    title = "GeoMx suppressive-program associations",
    workflow = "workflows/spatial/12_geomx_roi_validation.R",
    operation = "select",
    input = "Fig07_G.tsv",
    required = c("program", "estimate", "FDR"),
    output = "panel_G_data.tsv"
  ),
  list(
    panel = "H",
    title = "Paired Basal-high versus luminal-high comparison",
    workflow = "workflows/spatial/06_external_rctd.R -> workflows/spatial/11a_prepare_external_visium_scores.R -> workflows/spatial/11_external_visium_basal_axis.R",
    operation = "select",
    input = "Fig07_H.tsv",
    required = c("sample", "region_group", "component", "proportion"),
    output = "panel_H_data.tsv"
  ),
  list(
    panel = "I",
    title = "Paired Visium validation maps",
    workflow = "workflows/spatial/06_external_rctd.R -> workflows/spatial/11a_prepare_external_visium_scores.R -> workflows/spatial/11_external_visium_basal_axis.R",
    operation = "select",
    input = "Fig07_I.tsv",
    required = c("sample", "x", "y", "feature", "value"),
    output = "panel_I_data.tsv"
  )
)

audit <- run_figure_analysis("Fig07", panel_plan, opts)
write_run_metadata(
  opts$output_dir,
  "Fig07_analysis",
  opts,
  list(
    computational_panels = sum(audit$status == "written"),
    documented_noncomputational_panels =
      sum(audit$status == "documented_noncomputational_panel")
  )
)
