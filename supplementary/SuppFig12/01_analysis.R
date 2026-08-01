#!/usr/bin/env Rscript

# SuppFig12: Single-cell validation of bladder urothelial carcinoma cell-type annotations and SPP1/FAP/CXCR4-associated compartments
# The source workflow for each panel is recorded in panel_plan. This script
# checks the exported columns and writes the tables used for figure assembly.

source(file.path("core", "R", "cli.R"))
source(file.path("core", "R", "figure_assembly.R"))
opts <- parse_common_args()
set.seed(opts$seed)

panel_plan <- list(
  list(
    panel = "A",
    title = "Major-lineage UMAP",
    workflow = "workflows/single_cell/01_process_scrna.R",
    operation = "select",
    input = "SuppFig12_A.tsv",
    required = c("UMAP_1", "UMAP_2", "cell_type"),
    output = "panel_A_data.tsv"
  ),
  list(
    panel = "B",
    title = "Canonical lineage-marker dot plot",
    workflow = "workflows/single_cell/01b_annotation_and_markers.R -> workflows/single_cell/08_marker_visualization.R",
    operation = "select",
    input = "SuppFig12_B.tsv",
    required = c("cell_type", "gene", "average_expression", "percent_expressing"),
    output = "panel_B_data.tsv"
  ),
  list(
    panel = "C",
    title = "Neutrophil-marker audit",
    workflow = "workflows/single_cell/01b_annotation_and_markers.R -> workflows/single_cell/08_marker_visualization.R",
    operation = "select",
    input = "SuppFig12_C.tsv",
    required = c("cell_type", "gene", "average_expression", "percent_expressing"),
    output = "panel_C_data.tsv"
  ),
  list(
    panel = "D",
    title = "Myeloid reclustering and SPP1 density",
    workflow = "workflows/single_cell/01c_lineage_subclustering.R -> workflows/single_cell/01b_annotation_and_markers.R -> workflows/single_cell/08_marker_visualization.R",
    operation = "select",
    input = "SuppFig12_D.tsv",
    required = c("UMAP_1", "UMAP_2", "cell_state", "SPP1"),
    output = "panel_D_data.tsv"
  ),
  list(
    panel = "E",
    title = "Fibroblast reclustering and FAP density",
    workflow = "workflows/single_cell/01c_lineage_subclustering.R -> workflows/single_cell/01b_annotation_and_markers.R -> workflows/single_cell/08_marker_visualization.R",
    operation = "select",
    input = "SuppFig12_E.tsv",
    required = c("UMAP_1", "UMAP_2", "cell_state", "FAP"),
    output = "panel_E_data.tsv"
  ),
  list(
    panel = "F",
    title = "Endothelial reclustering and CXCR4 density",
    workflow = "workflows/single_cell/01c_lineage_subclustering.R -> workflows/single_cell/01b_annotation_and_markers.R -> workflows/single_cell/08_marker_visualization.R",
    operation = "select",
    input = "SuppFig12_F.tsv",
    required = c("UMAP_1", "UMAP_2", "cell_state", "CXCR4"),
    output = "panel_F_data.tsv"
  )
)

audit <- run_figure_analysis("SuppFig12", panel_plan, opts)
write_run_metadata(
  opts$output_dir,
  "SuppFig12_analysis",
  opts,
  list(
    computational_panels = sum(audit$status == "written"),
    documented_noncomputational_panels =
      sum(audit$status == "documented_noncomputational_panel")
  )
)
