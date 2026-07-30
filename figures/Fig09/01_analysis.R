#!/usr/bin/env Rscript

# Fig09: VEGFA TAN-CXCR4 tip EC angiogenic program
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
    title = "NMI-Basal component maps",
    workflow = "workflows/spatial/cell2location/",
    operation = "select",
    input = "Fig09_A.tsv",
    required = c("sample", "x", "y", "component", "q05_abundance"),
    output = "panel_A_data.tsv"
  ),
  list(
    panel = "B",
    title = "MI-Basal component maps",
    workflow = "workflows/spatial/cell2location/",
    operation = "select",
    input = "Fig09_B.tsv",
    required = c("sample", "x", "y", "component", "q05_abundance"),
    output = "panel_B_data.tsv"
  ),
  list(
    panel = "C",
    title = "Multiplex immunofluorescence",
    workflow = "non-computational source panel; code not applicable",
    operation = "document_only"
  ),
  list(
    panel = "D",
    title = "Selected CellChat interactions",
    workflow = "workflows/communication/01_cellchat.R",
    operation = "select",
    input = "Fig09_D.tsv",
    required = c("source", "target", "ligand", "receptor", "probability", "p_value"),
    output = "panel_D_data.tsv"
  ),
  list(
    panel = "E",
    title = "VEGFA-VEGFR1 spatial signal",
    workflow = "workflows/spatial/01_visium_preprocessing.R",
    operation = "select",
    input = "Fig09_E.tsv",
    required = c("sample", "x", "y", "interaction_score"),
    output = "panel_E_data.tsv"
  ),
  list(
    panel = "F",
    title = "NAMPT-INSR spatial signal",
    workflow = "workflows/spatial/01_visium_preprocessing.R",
    operation = "select",
    input = "Fig09_F.tsv",
    required = c("sample", "x", "y", "interaction_score"),
    output = "panel_F_data.tsv"
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
