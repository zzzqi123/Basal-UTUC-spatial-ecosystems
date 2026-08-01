#!/usr/bin/env Rscript

# SuppFig11: Bulk transcriptomic validation of the SPP1-associated Basal immune-stromal program in bladder urothelial carcinoma
# The source workflow for each panel is recorded in panel_plan. This script
# checks the exported columns and writes the tables used for figure assembly.

source(file.path("core", "R", "cli.R"))
source(file.path("core", "R", "figure_assembly.R"))
opts <- parse_common_args()
set.seed(opts$seed)

panel_plan <- list(
  list(
    panel = "A",
    title = "Immune and stromal scores",
    workflow = "workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/03_external_blca_validation.R",
    operation = "select",
    input = "SuppFig11_A.tsv",
    required = c("stage", "subtype", "score_name", "score_value"),
    output = "panel_A_data.tsv"
  ),
  list(
    panel = "B",
    title = "FAP and SPP1 expression",
    workflow = "workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/03_external_blca_validation.R",
    operation = "select",
    input = "SuppFig11_B.tsv",
    required = c("stage", "subtype", "gene", "expression"),
    output = "panel_B_data.tsv"
  ),
  list(
    panel = "C",
    title = "SPP1 correlations",
    workflow = "workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/03_external_blca_validation.R",
    operation = "select",
    input = "SuppFig11_C.tsv",
    required = c("score_name", "score_value", "SPP1"),
    output = "panel_C_data.tsv"
  ),
  list(
    panel = "D",
    title = "Subtype-classification ROC",
    workflow = "workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/03_external_blca_validation.R",
    operation = "select",
    input = "SuppFig11_D.tsv",
    required = c("marker", "fpr", "tpr", "auc"),
    output = "panel_D_data.tsv"
  ),
  list(
    panel = "E",
    title = "External survival validation",
    workflow = "workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/03_external_blca_validation.R",
    operation = "select",
    input = "SuppFig11_E.tsv",
    required = c("time", "survival", "dataset", "group"),
    output = "panel_E_data.tsv"
  )
)

audit <- run_figure_analysis("SuppFig11", panel_plan, opts)
write_run_metadata(
  opts$output_dir,
  "SuppFig11_analysis",
  opts,
  list(
    computational_panels = sum(audit$status == "written"),
    documented_noncomputational_panels =
      sum(audit$status == "documented_noncomputational_panel")
  )
)
