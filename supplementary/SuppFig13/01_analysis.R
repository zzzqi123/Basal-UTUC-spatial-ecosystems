#!/usr/bin/env Rscript

# SuppFig13: Cancer_c3 boundary analysis and independent Japan-UTUC association
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
    title = "Tumor threshold, boundary and signed-distance definition",
    workflow = "workflows/spatial/03_prepare_boundary_input.py -> workflows/spatial/04_infer_boundary_stgrads.R -> workflows/spatial/05_boundary_profiles.R",
    operation = "select",
    input = "SuppFig13_A.tsv",
    required = c("sample", "x", "y", "tumor_type", "tumor_interface_zone", "signed_distance"),
    output = "panel_A_data.tsv"
  ),
  list(
    panel = "B",
    title = "Section-specific Cancer_c3 boundary profiles",
    workflow = "workflows/spatial/03_prepare_boundary_input.py -> workflows/spatial/04_infer_boundary_stgrads.R -> workflows/spatial/05_boundary_profiles.R",
    operation = "select",
    input = "SuppFig13_B.tsv",
    required = c("sample", "cell_state", "signed_distance", "fitted_z", "se"),
    output = "panel_B_data.tsv"
  ),
  list(
    panel = "C",
    title = "Japan-UTUC Cancer_c3 muscle-invasion models",
    workflow = "workflows/bulk_clinical_validation/02_japan_utuc_validation.R",
    operation = "select",
    input = "SuppFig13_C.tsv",
    required = c("score", "endpoint", "model", "effect", "CI_low", "CI_high", "p_value", "FDR_BH"),
    output = "panel_C_data.tsv"
  )
)

audit <- run_figure_analysis("SuppFig13", panel_plan, opts)
write_run_metadata(
  opts$output_dir,
  "SuppFig13_analysis",
  opts,
  list(
    computational_panels = sum(audit$status == "written"),
    documented_noncomputational_panels =
      sum(audit$status == "documented_noncomputational_panel")
  )
)
