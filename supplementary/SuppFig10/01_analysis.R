#!/usr/bin/env Rscript

# SuppFig10: Transcriptional and spatial heterogeneity of mesenchymal and endothelial compartments in UTUC
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
    title = "Mesenchymal markers and GO terms",
    workflow = "workflows/single_cell/06_functional_enrichment.R",
    operation = "select",
    input = "SuppFig10_A.tsv",
    required = c("cell_state", "gene_or_term", "value", "kind"),
    output = "panel_A_data.tsv"
  ),
  list(
    panel = "B",
    title = "Spatial myogenesis score",
    workflow = "workflows/spatial/09_spacet_gene_set_scores.R",
    operation = "select",
    input = "SuppFig10_B.tsv",
    required = c("sample", "x", "y", "myogenesis_score"),
    output = "panel_B_data.tsv"
  ),
  list(
    panel = "C",
    title = "CAF_c3_FAP Hallmark enrichment",
    workflow = "workflows/single_cell/06_functional_enrichment.R",
    operation = "select",
    input = "SuppFig10_C.tsv",
    required = c("pathway", "NES", "FDR"),
    output = "panel_C_data.tsv"
  ),
  list(
    panel = "D",
    title = "Endothelial UMAP",
    workflow = "workflows/single_cell/01c_lineage_subclustering.R",
    operation = "select",
    input = "SuppFig10_D.tsv",
    required = c("UMAP_1", "UMAP_2", "cell_state"),
    output = "panel_D_data.tsv"
  ),
  list(
    panel = "E",
    title = "Endothelial marker dot plot",
    workflow = "workflows/single_cell/01b_annotation_and_markers.R -> workflows/single_cell/08_marker_visualization.R",
    operation = "select",
    input = "SuppFig10_E.tsv",
    required = c("cell_state", "gene", "average_expression", "percent_expressing"),
    output = "panel_E_data.tsv"
  ),
  list(
    panel = "F",
    title = "Endo_c1_CXCR4 enrichment",
    workflow = "workflows/single_cell/06_functional_enrichment.R",
    operation = "select",
    input = "SuppFig10_F.tsv",
    required = c("pathway", "NES", "FDR"),
    output = "panel_F_data.tsv"
  ),
  list(
    panel = "G",
    title = "Stromal and endothelial DSS",
    workflow = "workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R",
    operation = "select",
    input = "SuppFig10_G.tsv",
    required = c("time", "survival", "signature"),
    output = "panel_G_data.tsv"
  )
)

audit <- run_figure_analysis("SuppFig10", panel_plan, opts)
write_run_metadata(
  opts$output_dir,
  "SuppFig10_analysis",
  opts,
  list(
    computational_panels = sum(audit$status == "written"),
    documented_noncomputational_panels =
      sum(audit$status == "documented_noncomputational_panel")
  )
)
