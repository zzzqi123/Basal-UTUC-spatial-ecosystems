#!/usr/bin/env Rscript

# SuppFig02: Single-cell QC and annotation
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
    title = "Single-cell quality-control metrics",
    workflow = "workflows/single_cell/01_process_scrna.R",
    operation = "select",
    input = "SuppFig02_A.tsv",
    required = c("sample", "metric", "value"),
    output = "panel_A_data.tsv"
  ),
  list(
    panel = "B",
    title = "Lineage-marker density maps",
    workflow = "workflows/single_cell/01_process_scrna.R",
    operation = "select",
    input = "SuppFig02_B.tsv",
    required = c("UMAP_1", "UMAP_2", "gene", "expression"),
    output = "panel_B_data.tsv"
  ),
  list(
    panel = "C",
    title = "Major-cell-type proportions",
    workflow = "workflows/single_cell/01_process_scrna.R",
    operation = "select",
    input = "SuppFig02_C.tsv",
    required = c("sample_group", "cell_type", "proportion"),
    output = "panel_C_data.tsv"
  )
)

audit <- run_figure_analysis("SuppFig02", panel_plan, opts)
write_run_metadata(
  opts$output_dir,
  "SuppFig02_analysis",
  opts,
  list(
    computational_panels = sum(audit$status == "written"),
    documented_noncomputational_panels =
      sum(audit$status == "documented_noncomputational_panel")
  )
)
