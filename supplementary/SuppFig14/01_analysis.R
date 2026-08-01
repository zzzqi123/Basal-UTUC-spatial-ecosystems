#!/usr/bin/env Rscript

# SuppFig14: Tumor-boundary inference and functional characterization of spatial niches in Basal UTUC
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
    title = "Signed distance from the inferred tumor boundary",
    workflow = "workflows/spatial/03_prepare_boundary_input.py -> workflows/spatial/04_infer_boundary_stgrads.R -> workflows/spatial/05_boundary_profiles.R",
    operation = "select",
    input = "SuppFig14_A.tsv",
    required = c("sample", "x", "y", "tumor_type", "tumor_interface_zone", "signed_distance"),
    output = "panel_A_data.tsv"
  ),
  list(
    panel = "B",
    title = "Integrated Hallmark GSEA for each spatial niche",
    workflow = "workflows/spatial/14_niche_functional_analysis.R",
    operation = "select",
    input = "SuppFig14_B.tsv",
    required = c("niche", "pathway", "NES", "p_value", "FDR"),
    output = "panel_B_data.tsv"
  ),
  list(
    panel = "C",
    title = "Adjusted spatial niche-pathway associations in MI sections",
    workflow = "workflows/spatial/14_niche_functional_analysis.R",
    operation = "select",
    input = "SuppFig14_C.tsv",
    required = c("niche", "pathway", "beta", "CI_low", "CI_high", "p_value", "FDR"),
    output = "panel_C_data.tsv"
  )
)

audit <- run_figure_analysis("SuppFig14", panel_plan, opts)
write_run_metadata(
  opts$output_dir,
  "SuppFig14_analysis",
  opts,
  list(
    computational_panels = sum(audit$status == "written"),
    documented_noncomputational_panels =
      sum(audit$status == "documented_noncomputational_panel")
  )
)
