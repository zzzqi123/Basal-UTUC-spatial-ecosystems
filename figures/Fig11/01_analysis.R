#!/usr/bin/env Rscript

# Fig11: Clinical stratification and subtype-discrimination performance of SPP1 and FAP in UTUC
# The source workflow for each panel is recorded in panel_plan. This script
# checks the exported columns and writes the tables used for figure assembly.

source(file.path("core", "R", "cli.R"))
source(file.path("core", "R", "figure_assembly.R"))
opts <- parse_common_args()
set.seed(opts$seed)

panel_plan <- list(
  list(
    panel = "A",
    title = "DSS in Basal NMI versus Basal MI",
    workflow = "workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R",
    operation = "select",
    input = "Fig11_A.tsv",
    required = c("time", "survival", "stage"),
    output = "panel_A_data.tsv"
  ),
  list(
    panel = "B",
    title = "SPP1 and FAP correlations with Basal score",
    workflow = "workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R",
    operation = "select",
    input = "Fig11_B.tsv",
    required = c("gene", "expression", "basal_score"),
    output = "panel_B_data.tsv"
  ),
  list(
    panel = "C",
    title = "Subtype-classification ROC curves",
    workflow = "workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R",
    operation = "select",
    input = "Fig11_C.tsv",
    required = c("marker", "fpr", "tpr", "auc"),
    output = "panel_C_data.tsv"
  ),
  list(
    panel = "D",
    title = "Joint SPP1-FAP survival stratification",
    workflow = "workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R",
    operation = "select",
    input = "Fig11_D.tsv",
    required = c("time", "survival", "group"),
    output = "panel_D_data.tsv"
  ),
  list(
    panel = "E",
    title = "Time-dependent DSS AUC",
    workflow = "workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R",
    operation = "select",
    input = "Fig11_E.tsv",
    required = c("year", "model", "auc"),
    output = "panel_E_data.tsv"
  )
)

audit <- run_figure_analysis("Fig11", panel_plan, opts)
write_run_metadata(
  opts$output_dir,
  "Fig11_analysis",
  opts,
  list(
    computational_panels = sum(audit$status == "written"),
    documented_noncomputational_panels =
      sum(audit$status == "documented_noncomputational_panel")
  )
)
