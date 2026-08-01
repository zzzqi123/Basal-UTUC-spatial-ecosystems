#!/usr/bin/env Rscript

# Fig01: Molecular subtype, pathological stage, and the tumor microenvironment in UTUC
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
    title = "Molecular subtype distribution by stage",
    workflow = "workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R",
    operation = "select",
    input = "Fig01_A.tsv",
    required = c("stage", "subtype", "n", "proportion"),
    output = "panel_A_data.tsv"
  ),
  list(
    panel = "B",
    title = "Subtype-stratified disease-specific survival",
    workflow = "workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R",
    operation = "select",
    input = "Fig01_B.tsv",
    required = c("time", "survival", "subtype", "endpoint"),
    output = "panel_B_data.tsv"
  ),
  list(
    panel = "C",
    title = "Immune and stromal scores within stage",
    workflow = "workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R",
    operation = "select",
    input = "Fig01_C.tsv",
    required = c("stage", "subtype", "score_name", "score_value"),
    output = "panel_C_data.tsv"
  ),
  list(
    panel = "D",
    title = "Single-cell UMAP of major lineages",
    workflow = "workflows/single_cell/01_process_scrna.R",
    operation = "select",
    input = "Fig01_D.tsv",
    required = c("UMAP_1", "UMAP_2", "major_celltype"),
    output = "panel_D_data.tsv"
  ),
  list(
    panel = "E",
    title = "Representative lineage-marker dot plot",
    workflow = "workflows/single_cell/01b_annotation_and_markers.R -> workflows/single_cell/08_marker_visualization.R",
    operation = "select",
    input = "Fig01_E.tsv",
    required = c("cell_type", "gene", "average_expression", "percent_expressing"),
    output = "panel_E_data.tsv"
  ),
  list(
    panel = "F",
    title = "Relative enrichment of major cell types",
    workflow = "workflows/single_cell/09_roe_composition.R",
    operation = "select",
    input = "Fig01_F.tsv",
    required = c("sample_group", "cell_type", "roe"),
    output = "panel_F_data.tsv"
  )
)

audit <- run_figure_analysis("Fig01", panel_plan, opts)
write_run_metadata(
  opts$output_dir,
  "Fig01_analysis",
  opts,
  list(
    computational_panels = sum(audit$status == "written"),
    documented_noncomputational_panels =
      sum(audit$status == "documented_noncomputational_panel")
  )
)
