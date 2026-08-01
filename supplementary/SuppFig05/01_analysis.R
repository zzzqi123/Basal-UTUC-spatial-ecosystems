#!/usr/bin/env Rscript

# SuppFig05: Developmental trajectories define functionally and spatially distinct malignant epithelial states in UTUC
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
    title = "Adjacent-epithelial-reference inferCNV heatmap",
    workflow = "workflows/single_cell/02a_infercnv_adjacent_epithelial_reference.R",
    operation = "select",
    input = "SuppFig05_A.tsv",
    required = c("cell_id", "chromosome", "position", "cnv_value"),
    output = "panel_A_data.tsv"
  ),
  list(
    panel = "B",
    title = "Malignant epithelial UMAP",
    workflow = "workflows/single_cell/02a_infercnv_adjacent_epithelial_reference.R",
    operation = "select",
    input = "SuppFig05_B.tsv",
    required = c("UMAP_1", "UMAP_2", "cell_state"),
    output = "panel_B_data.tsv"
  ),
  list(
    panel = "C",
    title = "CytoTRACE2 and Monocle3 trajectories",
    workflow = "workflows/single_cell/04_cytotrace2.R -> workflows/single_cell/03b_monocle3_robustness.R",
    operation = "select",
    input = "SuppFig05_C.tsv",
    required = c("embedding_1", "embedding_2", "analysis", "value", "cell_state"),
    output = "panel_C_data.tsv"
  ),
  list(
    panel = "D",
    title = "Basal-marker density",
    workflow = "workflows/single_cell/01b_annotation_and_markers.R -> workflows/single_cell/08_marker_visualization.R",
    operation = "select",
    input = "SuppFig05_D.tsv",
    required = c("UMAP_1", "UMAP_2", "gene", "expression"),
    output = "panel_D_data.tsv"
  ),
  list(
    panel = "E",
    title = "Malignant-state spatial maps",
    workflow = "workflows/spatial/cell2location/",
    operation = "select",
    input = "SuppFig05_E.tsv",
    required = c("sample", "x", "y", "cell_state", "q05_abundance"),
    output = "panel_E_data.tsv"
  ),
  list(
    panel = "F",
    title = "Cancer_c0 and Cancer_c3 niche distribution",
    workflow = "workflows/spatial/cell2location/",
    operation = "select",
    input = "SuppFig05_F.tsv",
    required = c("sample", "spatial_niche", "cell_state", "median_abundance"),
    output = "panel_F_data.tsv"
  ),
  list(
    panel = "G",
    title = "Cancer_c0 and Cancer_c3 DSS",
    workflow = "workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R",
    operation = "select",
    input = "SuppFig05_G.tsv",
    required = c("time", "survival", "signature"),
    output = "panel_G_data.tsv"
  ),
  list(
    panel = "H",
    title = "Top malignant regulons",
    workflow = "workflows/single_cell/05_pyscenic.sh",
    operation = "select",
    input = "SuppFig05_H.tsv",
    required = c("cell_state", "regulon", "auc"),
    output = "panel_H_data.tsv"
  ),
  list(
    panel = "I",
    title = "Cancer_c0 enrichment",
    workflow = "workflows/single_cell/06_functional_enrichment.R",
    operation = "select",
    input = "SuppFig05_I.tsv",
    required = c("pathway", "NES", "FDR"),
    output = "panel_I_data.tsv"
  ),
  list(
    panel = "J",
    title = "PROGENy activity",
    workflow = "workflows/single_cell/07_pathway_activity.R",
    operation = "select",
    input = "SuppFig05_J.tsv",
    required = c("cell_state", "pathway", "activity"),
    output = "panel_J_data.tsv"
  )
)

audit <- run_figure_analysis("SuppFig05", panel_plan, opts)
write_run_metadata(
  opts$output_dir,
  "SuppFig05_analysis",
  opts,
  list(
    computational_panels = sum(audit$status == "written"),
    documented_noncomputational_panels =
      sum(audit$status == "documented_noncomputational_panel")
  )
)
