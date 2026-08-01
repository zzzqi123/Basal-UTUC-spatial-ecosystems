#!/usr/bin/env Rscript

# Fig09: Spatial coupling and ligand-receptor interactions between CXCR4+ tip ECs and VEGFA+ TAN in Basal UTUC
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
    title = "Selected VEGFA TAN-tip EC ligand-receptor probabilities",
    workflow = "workflows/single_cell/11_cellchat.R",
    operation = "select",
    input = "Fig09_A.tsv",
    required = c("source", "target", "ligand", "receptor", "probability", "p_value"),
    output = "panel_A_data.tsv"
  ),
  list(
    panel = "B",
    title = "VEGFA-VEGFR1 spatial signal",
    workflow = "workflows/spatial/08_spagene_lr_colocalization.R",
    operation = "select",
    input = "Fig09_B.tsv",
    required = c("sample", "x", "y", "interaction_score"),
    output = "panel_B_data.tsv"
  ),
  list(
    panel = "C",
    title = "NAMPT-INSR spatial signal",
    workflow = "workflows/spatial/08_spagene_lr_colocalization.R",
    operation = "select",
    input = "Fig09_C.tsv",
    required = c("sample", "x", "y", "interaction_score"),
    output = "panel_C_data.tsv"
  ),
  list(
    panel = "D",
    title = "NMI-Basal VEGFA TAN-tip EC co-localization",
    workflow = "workflows/spatial/07_cellstate_correlation_colocalization.R",
    operation = "select",
    input = "Fig09_D.tsv",
    required = c("sample", "x", "y", "pair_id", "colocalization_score"),
    output = "panel_D_data.tsv"
  ),
  list(
    panel = "E",
    title = "MI-Basal VEGFA TAN-tip EC co-localization",
    workflow = "workflows/spatial/07_cellstate_correlation_colocalization.R",
    operation = "select",
    input = "Fig09_E.tsv",
    required = c("sample", "x", "y", "pair_id", "colocalization_score"),
    output = "panel_E_data.tsv"
  ),
  list(
    panel = "F",
    title = "Multiplex immunofluorescence",
    workflow = "non-computational source panel; code not applicable",
    operation = "document_only"
  )
)

audit <- run_figure_analysis("Fig09", panel_plan, opts)
write_run_metadata(
  opts$output_dir,
  "Fig09_analysis",
  opts,
  list(
    computational_panels = sum(audit$status == "written"),
    documented_noncomputational_panels =
      sum(audit$status == "documented_noncomputational_panel")
  )
)
