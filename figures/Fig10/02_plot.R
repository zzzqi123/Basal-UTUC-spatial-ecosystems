#!/usr/bin/env Rscript

# Fig10 panel rendering.
# Standard panels are rendered from the exported tables below. Panels drawn
# directly by an analysis package are listed in package_native_panels.

source(file.path("core", "R", "cli.R"))
source(file.path("core", "R", "figure_assembly.R"))
opts <- parse_common_args()

plot_plan <- list(
  list(
    panel = "A",
    title = "Section-level multiscale pair burden",
    input = "panel_A_data.tsv",
    geometry = "line",
    x = "ring",
    y = "fold_vs_nmi",
    group = "section",
    colour = "section",
    facet = "program",
    output = "panel_A.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "B",
    title = "Permutation-based spatial observed-to-expected",
    input = "panel_B_data.tsv",
    geometry = "line",
    x = "ring",
    y = "spatial_oe",
    group = "section",
    colour = "section",
    facet = "program",
    output = "panel_B.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "C",
    title = "Section-specific signed-distance profiles",
    input = "panel_C_data.tsv",
    geometry = "line",
    x = "signed_distance",
    y = "fitted_z",
    group = "cell_state",
    colour = "cell_state",
    facet = "sample",
    output = "panel_C.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "D",
    title = "GSE319536 continuous Basal-luminal validation",
    input = "panel_D_data.tsv",
    geometry = "line",
    x = "basal_luminal_percentile",
    y = "mean_curve",
    group = "ring",
    colour = "ring",
    output = "panel_D.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "E",
    title = "Japan-UTUC cellular-program clinical models",
    input = "panel_E_data.tsv",
    geometry = "forest",
    effect = "effect",
    term = "score",
    lower = "CI_low",
    upper = "CI_high",
    facet = "endpoint",
    output = "panel_E.pdf",
    width = 5.5,
    height = 4.2
  )
)

if (length(plot_plan)) {
  run_figure_plots("Fig10", plot_plan, opts)
}

package_native_panels <- tibble::tibble(
  panel = character(), title = character(), workflow = character()
)

write_run_metadata(
  opts$output_dir,
  "Fig10_plot",
  opts,
  list(
    standard_vector_panels = length(plot_plan),
    package_native_panels = nrow(package_native_panels)
  )
)
