#!/usr/bin/env Rscript

# Fig02: Spatial transcriptomic landscape of Basal UTUC
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
    title = "cell2location major-cell-type maps",
    workflow = "workflows/spatial/cell2location/",
    operation = "select",
    input = "Fig02_A.tsv",
    required = c("sample", "x", "y", "cell_type", "q05_abundance"),
    output = "panel_A_data.tsv"
  ),
  list(
    panel = "B",
    title = "Within-section cell-state correlations",
    workflow = "workflows/spatial/07_cellstate_correlation_colocalization.R",
    operation = "select",
    input = "Fig02_B.tsv",
    required = c("sample", "state_1", "state_2", "spearman_rho"),
    output = "panel_B_data.tsv"
  ),
  list(
    panel = "C",
    title = "CK5/6, GATA3, FAP and SPP1 immunohistochemistry",
    workflow = "non-computational source panel; code not applicable",
    operation = "document_only"
  )
)

audit <- run_figure_analysis("Fig02", panel_plan, opts)
write_run_metadata(
  opts$output_dir,
  "Fig02_analysis",
  opts,
  list(
    computational_panels = sum(audit$status == "written"),
    documented_noncomputational_panels =
      sum(audit$status == "documented_noncomputational_panel")
  )
)
