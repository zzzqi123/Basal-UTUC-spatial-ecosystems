#!/usr/bin/env Rscript

# SuppFig13 panel rendering.
# Standard statistical panels are rendered from the exported tables below.
# Package-native graphs (CellChat, Seurat dot plots, inferCNV, SCENIC) remain
# identified explicitly instead of being replaced with a misleading generic plot.

source(file.path("core", "R", "cli.R"))
source(file.path("core", "R", "figure_assembly.R"))
opts <- parse_common_args()

plot_plan <- list(
  list(
    panel = "A",
    title = "Tumor threshold, boundary and signed-distance definition",
    input = "panel_A_data.tsv",
    geometry = "point",
    x = "x",
    y = "y",
    colour = "signed_distance",
    facet = "sample",
    output = "panel_A.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "B",
    title = "Section-specific Cancer_c3 boundary profiles",
    input = "panel_B_data.tsv",
    geometry = "line",
    x = "signed_distance",
    y = "fitted_z",
    group = "sample",
    colour = "sample",
    output = "panel_B.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "C",
    title = "Japan-UTUC Cancer_c3 muscle-invasion models",
    input = "panel_C_data.tsv",
    geometry = "forest",
    effect = "effect",
    term = "model",
    lower = "CI_low",
    upper = "CI_high",
    output = "panel_C.pdf",
    width = 5.5,
    height = 4.2
  )
)

if (length(plot_plan)) {
  run_figure_plots("SuppFig13", plot_plan, opts)
}

package_native_panels <- tibble::tibble(
  panel = character(), title = character(), workflow = character()
)

write_run_metadata(
  opts$output_dir,
  "SuppFig13_plot",
  opts,
  list(
    standard_vector_panels = length(plot_plan),
    package_native_panels = nrow(package_native_panels)
  )
)
