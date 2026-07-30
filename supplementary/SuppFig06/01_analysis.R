#!/usr/bin/env Rscript

# SuppFig06: Malignant trajectories, programs and clinical relevance
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
    title = "Top markers and GO terms",
    workflow = "workflows/single_cell/06_functional_enrichment.R",
    operation = "select",
    input = "SuppFig06_A.tsv",
    required = c("cell_state", "gene_or_term", "value", "kind"),
    output = "panel_A_data.tsv"
  ),
  list(
    panel = "B",
    title = "PCA-based malignant trajectory",
    workflow = "workflows/single_cell/03_trajectory_analysis.R",
    operation = "select",
    input = "SuppFig06_B.tsv",
    required = c("PCA_1", "PCA_2", "cell_state", "pseudotime"),
    output = "panel_B_data.tsv"
  ),
  list(
    panel = "C",
    title = "Monocle3 pseudotime embeddings",
    workflow = "workflows/single_cell/03_trajectory_analysis.R",
    operation = "select",
    input = "SuppFig06_C.tsv",
    required = c("embedding_1", "embedding_2", "embedding", "pseudotime"),
    output = "panel_C_data.tsv"
  ),
  list(
    panel = "D",
    title = "Representative regulon activities",
    workflow = "workflows/single_cell/05_pyscenic.sh",
    operation = "select",
    input = "SuppFig06_D.tsv",
    required = c("cell_state", "regulon", "auc"),
    output = "panel_D_data.tsv"
  ),
  list(
    panel = "E",
    title = "Cancer_c3 Hallmark enrichment",
    workflow = "workflows/single_cell/06_functional_enrichment.R",
    operation = "select",
    input = "SuppFig06_E.tsv",
    required = c("pathway", "NES", "FDR"),
    output = "panel_E_data.tsv"
  ),
  list(
    panel = "F",
    title = "Cancer_c3-Basal score correlation",
    workflow = "workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R",
    operation = "select",
    input = "SuppFig06_F.tsv",
    required = c("cancer_c3_score", "basal_score"),
    output = "panel_F_data.tsv"
  ),
  list(
    panel = "G",
    title = "Cancer_c4 DSS",
    workflow = "workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R",
    operation = "select",
    input = "SuppFig06_G.tsv",
    required = c("time", "survival", "group"),
    output = "panel_G_data.tsv"
  ),
  list(
    panel = "H",
    title = "Cancer_c4 enrichment",
    workflow = "workflows/single_cell/06_functional_enrichment.R",
    operation = "select",
    input = "SuppFig06_H.tsv",
    required = c("pathway", "NES", "FDR"),
    output = "panel_H_data.tsv"
  )
)

audit <- run_figure_analysis("SuppFig06", panel_plan, opts)
write_run_metadata(
  opts$output_dir,
  "SuppFig06_analysis",
  opts,
  list(
    computational_panels = sum(audit$status == "written"),
    documented_noncomputational_panels =
      sum(audit$status == "documented_noncomputational_panel")
  )
)
