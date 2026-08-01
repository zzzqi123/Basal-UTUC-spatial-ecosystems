#!/usr/bin/env Rscript

# SuppFig01: Molecular subtype distribution and tumor microenvironment-related features across stages
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
    title = "Subtype distribution across stages",
    workflow = "workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R",
    operation = "select",
    input = "SuppFig01_A.tsv",
    required = c("stage", "subtype", "n", "proportion"),
    output = "panel_A_data.tsv"
  ),
  list(
    panel = "B",
    title = "Tumor purity within stage",
    workflow = "workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R",
    operation = "select",
    input = "SuppFig01_B.tsv",
    required = c("stage", "subtype", "purity"),
    output = "panel_B_data.tsv"
  ),
  list(
    panel = "C",
    title = "Immune, myeloid and stromal marker expression",
    workflow = "workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R",
    operation = "select",
    input = "SuppFig01_C.tsv",
    required = c("stage", "subtype", "gene", "expression"),
    output = "panel_C_data.tsv"
  ),
  list(
    panel = "D",
    title = "Major-cell-type Sankey summary",
    workflow = "workflows/single_cell/01_process_scrna.R",
    operation = "select",
    input = "SuppFig01_D.tsv",
    required = c("sample_group", "cell_type", "n", "proportion"),
    output = "panel_D_data.tsv"
  )
)

audit <- run_figure_analysis("SuppFig01", panel_plan, opts)
write_run_metadata(
  opts$output_dir,
  "SuppFig01_analysis",
  opts,
  list(
    computational_panels = sum(audit$status == "written"),
    documented_noncomputational_panels =
      sum(audit$status == "documented_noncomputational_panel")
  )
)
