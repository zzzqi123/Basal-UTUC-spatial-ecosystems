#!/usr/bin/env Rscript

# SuppFig07: Myeloid subcluster characterization
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
    title = "Canonical marker dot plot",
    workflow = "workflows/single_cell/01b_annotation_and_markers.R -> workflows/single_cell/08_marker_visualization.R",
    operation = "select",
    input = "SuppFig07_A.tsv",
    required = c("cell_state", "gene", "average_expression", "percent_expressing"),
    output = "panel_A_data.tsv"
  ),
  list(
    panel = "B",
    title = "Markers and GO terms",
    workflow = "workflows/single_cell/06_functional_enrichment.R",
    operation = "select",
    input = "SuppFig07_B.tsv",
    required = c("cell_state", "gene_or_term", "value", "kind"),
    output = "panel_B_data.tsv"
  ),
  list(
    panel = "C",
    title = "Subcluster density along pseudotime",
    workflow = "workflows/single_cell/03_trajectory_analysis.R",
    operation = "select",
    input = "SuppFig07_C.tsv",
    required = c("pseudotime", "cell_state", "density"),
    output = "panel_C_data.tsv"
  ),
  list(
    panel = "D",
    title = "CCR2-SPP1 co-localization and M2 spatial scores",
    workflow = "workflows/spatial/07_cellstate_correlation_colocalization.R -> workflows/spatial/09_spacet_gene_set_scores.R",
    operation = "select",
    input = "SuppFig07_D.tsv",
    required = c("sample", "x", "y", "feature", "value"),
    output = "panel_D_data.tsv"
  ),
  list(
    panel = "E",
    title = "Dendritic-cell DSS",
    workflow = "workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R",
    operation = "select",
    input = "SuppFig07_E.tsv",
    required = c("time", "survival", "signature"),
    output = "panel_E_data.tsv"
  )
)

audit <- run_figure_analysis("SuppFig07", panel_plan, opts)
write_run_metadata(
  opts$output_dir,
  "SuppFig07_analysis",
  opts,
  list(
    computational_panels = sum(audit$status == "written"),
    documented_noncomputational_panels =
      sum(audit$status == "documented_noncomputational_panel")
  )
)
