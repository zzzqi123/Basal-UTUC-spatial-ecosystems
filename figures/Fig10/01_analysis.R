#!/usr/bin/env Rscript

# Fig10: Multiscale spatial and clinical comparison of two microenvironmental programs in Basal UTUC
# The source workflow for each panel is recorded in panel_plan. This script
# checks the exported columns and writes the tables used for figure assembly.

source(file.path("core", "R", "cli.R"))
source(file.path("core", "R", "figure_assembly.R"))
opts <- parse_common_args()
set.seed(opts$seed)

panel_plan <- list(
  list(
    panel = "A",
    title = "Section-level multiscale pair burden",
    workflow = "workflows/spatial/02_multiscale_pair_burden.py",
    operation = "select",
    input = "Fig10_A.tsv",
    required = c("section", "program", "ring", "pair_burden", "fold_vs_nmi"),
    output = "panel_A_data.tsv"
  ),
  list(
    panel = "B",
    title = "Permutation-based spatial observed-to-expected",
    workflow = "workflows/spatial/02_multiscale_pair_burden.py",
    operation = "select",
    input = "Fig10_B.tsv",
    required = c("section", "program", "ring", "spatial_oe", "permutation_p_upper"),
    output = "panel_B_data.tsv"
  ),
  list(
    panel = "C",
    title = "Section-specific signed-distance profiles",
    workflow = "workflows/spatial/03_prepare_boundary_input.py -> workflows/spatial/04_infer_boundary_stgrads.R -> workflows/spatial/05_boundary_profiles.R",
    operation = "select",
    input = "Fig10_C.tsv",
    required = c("sample", "cell_state", "signed_distance", "fitted_z", "se"),
    output = "panel_C_data.tsv"
  ),
  list(
    panel = "D",
    title = "GSE319536 continuous Basal-luminal validation",
    workflow = "workflows/spatial/06_rctd_deconvolution.R -> workflows/spatial/11a_prepare_external_visium_scores.R -> workflows/spatial/11_external_visium_basal_axis.R",
    operation = "select",
    input = "Fig10_D.tsv",
    required = c("basal_luminal_percentile", "ring", "pair_score", "mean_curve", "ci_low", "ci_high"),
    output = "panel_D_data.tsv"
  ),
  list(
    panel = "E",
    title = "Japan-UTUC cellular-program clinical models",
    workflow = "workflows/bulk_clinical_validation/02_japan_utuc_validation.R",
    operation = "select",
    input = "Fig10_E.tsv",
    required = c("score", "endpoint", "model", "effect", "CI_low", "CI_high", "p_value", "FDR_BH"),
    output = "panel_E_data.tsv"
  )
)

audit <- run_figure_analysis("Fig10", panel_plan, opts)
write_run_metadata(
  opts$output_dir,
  "Fig10_analysis",
  opts,
  list(
    computational_panels = sum(audit$status == "written"),
    documented_noncomputational_panels =
      sum(audit$status == "documented_noncomputational_panel")
  )
)
