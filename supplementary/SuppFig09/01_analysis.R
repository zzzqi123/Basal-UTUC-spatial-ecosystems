#!/usr/bin/env Rscript

# SuppFig09: Transcriptional and functional heterogeneity of lymphoid subclusters in UTUC
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
    title = "CD4 T-cell UMAP",
    workflow = "workflows/single_cell/01c_lineage_subclustering.R",
    operation = "select",
    input = "SuppFig09_A.tsv",
    required = c("UMAP_1", "UMAP_2", "cell_state"),
    output = "panel_A_data.tsv"
  ),
  list(
    panel = "B",
    title = "CD4 markers and functions",
    workflow = "workflows/single_cell/06_functional_enrichment.R",
    operation = "select",
    input = "SuppFig09_B.tsv",
    required = c("cell_state", "gene_or_term", "value", "kind"),
    output = "panel_B_data.tsv"
  ),
  list(
    panel = "C",
    title = "CD4 relative enrichment",
    workflow = "workflows/single_cell/09_roe_composition.R",
    operation = "select",
    input = "SuppFig09_C.tsv",
    required = c("sample_group", "cell_state", "roe"),
    output = "panel_C_data.tsv"
  ),
  list(
    panel = "D",
    title = "CD8 T-cell UMAP",
    workflow = "workflows/single_cell/01c_lineage_subclustering.R",
    operation = "select",
    input = "SuppFig09_D.tsv",
    required = c("UMAP_1", "UMAP_2", "cell_state"),
    output = "panel_D_data.tsv"
  ),
  list(
    panel = "E",
    title = "CD8 markers and functions",
    workflow = "workflows/single_cell/06_functional_enrichment.R",
    operation = "select",
    input = "SuppFig09_E.tsv",
    required = c("cell_state", "gene_or_term", "value", "kind"),
    output = "panel_E_data.tsv"
  ),
  list(
    panel = "F",
    title = "CD8 functional programs",
    workflow = "workflows/single_cell/07_pathway_activity.R",
    operation = "select",
    input = "SuppFig09_F.tsv",
    required = c("cell_state", "program", "score"),
    output = "panel_F_data.tsv"
  ),
  list(
    panel = "G",
    title = "B-cell DSS",
    workflow = "workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R",
    operation = "select",
    input = "SuppFig09_G.tsv",
    required = c("time", "survival", "signature"),
    output = "panel_G_data.tsv"
  ),
  list(
    panel = "H",
    title = "Lymphoid-marker correlations",
    workflow = "workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R",
    operation = "select",
    input = "SuppFig09_H.tsv",
    required = c("signature", "marker", "rho"),
    output = "panel_H_data.tsv"
  )
)

audit <- run_figure_analysis("SuppFig09", panel_plan, opts)
write_run_metadata(
  opts$output_dir,
  "SuppFig09_analysis",
  opts,
  list(
    computational_panels = sum(audit$status == "written"),
    documented_noncomputational_panels =
      sum(audit$status == "documented_noncomputational_panel")
  )
)
