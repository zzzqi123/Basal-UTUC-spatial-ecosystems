#!/usr/bin/env Rscript

# SuppFig04: Spatial transcriptomic analysis of Basal UTUC across pathological stages
# The source workflow for each panel is recorded in panel_plan. This script
# checks the exported columns and writes the tables used for figure assembly.

source(file.path("core", "R", "cli.R"))
source(file.path("core", "R", "figure_assembly.R"))
opts <- parse_common_args()
set.seed(opts$seed)

panel_plan <- list(
  list(
    panel = "A",
    title = "H&E images of profiled sections",
    workflow = "non-computational source panel; code not applicable",
    operation = "document_only"
  ),
  list(
    panel = "B",
    title = "q05 abundance Leiden niches",
    workflow = "workflows/spatial/cell2location/",
    operation = "select",
    input = "SuppFig04_B.tsv",
    required = c("sample", "x", "y", "spatial_niche"),
    output = "panel_B_data.tsv"
  ),
  list(
    panel = "C",
    title = "cell2location cell-state maps",
    workflow = "workflows/spatial/cell2location/",
    operation = "select",
    input = "SuppFig04_C.tsv",
    required = c("sample", "x", "y", "cell_state", "q05_abundance"),
    output = "panel_C_data.tsv"
  ),
  list(
    panel = "D",
    title = "Spatial Basal signature",
    workflow = "workflows/spatial/01_visium_preprocessing.R",
    operation = "select",
    input = "SuppFig04_D.tsv",
    required = c("sample", "x", "y", "basal_score"),
    output = "panel_D_data.tsv"
  )
)

audit <- run_figure_analysis("SuppFig04", panel_plan, opts)
write_run_metadata(
  opts$output_dir,
  "SuppFig04_analysis",
  opts,
  list(
    computational_panels = sum(audit$status == "written"),
    documented_noncomputational_panels =
      sum(audit$status == "documented_noncomputational_panel")
  )
)
