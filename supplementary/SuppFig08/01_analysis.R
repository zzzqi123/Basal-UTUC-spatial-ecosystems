#!/usr/bin/env Rscript

# SuppFig08: Transcriptional heterogeneity and spatial organization of lymphoid subclusters in UTUC
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
    title = "Lymphoid UMAP",
    workflow = "workflows/single_cell/01c_lineage_subclustering.R",
    operation = "select",
    input = "SuppFig08_A.tsv",
    required = c("UMAP_1", "UMAP_2", "cell_state"),
    output = "panel_A_data.tsv"
  ),
  list(
    panel = "B",
    title = "CD4 functional programs",
    workflow = "workflows/single_cell/07_pathway_activity.R",
    operation = "select",
    input = "SuppFig08_B.tsv",
    required = c("cell_state", "program", "score"),
    output = "panel_B_data.tsv"
  ),
  list(
    panel = "C",
    title = "Lymphoid-state DSS",
    workflow = "workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R",
    operation = "select",
    input = "SuppFig08_C.tsv",
    required = c("time", "survival", "signature"),
    output = "panel_C_data.tsv"
  ),
  list(
    panel = "D",
    title = "CD8 relative enrichment",
    workflow = "workflows/single_cell/09_roe_composition.R",
    operation = "select",
    input = "SuppFig08_D.tsv",
    required = c("sample_group", "cell_state", "roe"),
    output = "panel_D_data.tsv"
  ),
  list(
    panel = "E",
    title = "Spatial T-cell program scores",
    workflow = "workflows/spatial/09_spacet_gene_set_scores.R",
    operation = "select",
    input = "SuppFig08_E.tsv",
    required = c("sample", "x", "y", "program", "score"),
    output = "panel_E_data.tsv"
  )
)

audit <- run_figure_analysis("SuppFig08", panel_plan, opts)
write_run_metadata(
  opts$output_dir,
  "SuppFig08_analysis",
  opts,
  list(
    computational_panels = sum(audit$status == "written"),
    documented_noncomputational_panels =
      sum(audit$status == "documented_noncomputational_panel")
  )
)
