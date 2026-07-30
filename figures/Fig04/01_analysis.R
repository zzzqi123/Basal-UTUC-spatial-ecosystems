#!/usr/bin/env Rscript

# Fig04: Stromal and endothelial cell states
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
    title = "Mesenchymal UMAP",
    workflow = "workflows/single_cell/01c_lineage_subclustering.R",
    operation = "select",
    input = "Fig04_A.tsv",
    required = c("UMAP_1", "UMAP_2", "cell_state"),
    output = "panel_A_data.tsv"
  ),
  list(
    panel = "B",
    title = "Mesenchymal pseudotime branches",
    workflow = "workflows/single_cell/03_trajectory_analysis.R",
    operation = "select",
    input = "Fig04_B.tsv",
    required = c("pseudotime", "cell_state", "density"),
    output = "panel_B_data.tsv"
  ),
  list(
    panel = "C",
    title = "CAF functional-state radar summary",
    workflow = "workflows/single_cell/07_pathway_activity.R",
    operation = "select",
    input = "Fig04_C.tsv",
    required = c("cell_state", "program", "score"),
    output = "panel_C_data.tsv"
  ),
  list(
    panel = "D",
    title = "myCAF correlations with Basal and TGF-beta scores",
    workflow = "workflows/single_cell/07_pathway_activity.R",
    operation = "select",
    input = "Fig04_D.tsv",
    required = c("x_score", "y_score", "x_value", "y_value"),
    output = "panel_D_data.tsv"
  ),
  list(
    panel = "E",
    title = "Tip-cell correlations with myCAF and hypoxia",
    workflow = "workflows/single_cell/07_pathway_activity.R",
    operation = "select",
    input = "Fig04_E.tsv",
    required = c("x_score", "y_score", "x_value", "y_value"),
    output = "panel_E_data.tsv"
  ),
  list(
    panel = "F",
    title = "Stromal and endothelial spatial maps",
    workflow = "workflows/spatial/cell2location/",
    operation = "select",
    input = "Fig04_F.tsv",
    required = c("sample", "x", "y", "cell_state", "q05_abundance"),
    output = "panel_F_data.tsv"
  )
)

audit <- run_figure_analysis("Fig04", panel_plan, opts)
write_run_metadata(
  opts$output_dir,
  "Fig04_analysis",
  opts,
  list(
    computational_panels = sum(audit$status == "written"),
    documented_noncomputational_panels =
      sum(audit$status == "documented_noncomputational_panel")
  )
)
