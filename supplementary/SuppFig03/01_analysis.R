#!/usr/bin/env Rscript

# SuppFig03: GWAS integration with single-cell profiles
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
    title = "Annotated single-cell t-SNE",
    workflow = "workflows/single_cell/01_process_scrna.R",
    operation = "select",
    input = "SuppFig03_A.tsv",
    required = c("tSNE_1", "tSNE_2", "cell_type"),
    output = "panel_A_data.tsv"
  ),
  list(
    panel = "B",
    title = "Cell-level scPagwas adjusted FDR",
    workflow = "workflows/genetics/01_scpagwas.R -> workflows/genetics/02_prepare_scpagwas_tables.R",
    operation = "select",
    input = "SuppFig03_B.tsv",
    required = c("cell_id", "tSNE_1", "tSNE_2", "Random_Correct_BG_adjp"),
    output = "panel_B_data.tsv"
  ),
  list(
    panel = "C",
    title = "Cell-type scPagwas bootstrap FDR",
    workflow = "workflows/genetics/01_scpagwas.R -> workflows/genetics/02_prepare_scpagwas_tables.R",
    operation = "select",
    input = "SuppFig03_C.tsv",
    required = c("cell_type", "bootstrap_bp_value", "celltype_FDR"),
    output = "panel_C_data.tsv"
  )
)

audit <- run_figure_analysis("SuppFig03", panel_plan, opts)
write_run_metadata(
  opts$output_dir,
  "SuppFig03_analysis",
  opts,
  list(
    computational_panels = sum(audit$status == "written"),
    documented_noncomputational_panels =
      sum(audit$status == "documented_noncomputational_panel")
  )
)
