#!/usr/bin/env Rscript

# SuppFig04 panel rendering.
# Standard statistical panels are rendered from the exported tables below.
# Package-native graphs (CellChat, Seurat dot plots, inferCNV, SCENIC) remain
# identified explicitly instead of being replaced with a misleading generic plot.

source(file.path("core", "R", "cli.R"))
source(file.path("core", "R", "figure_assembly.R"))
opts <- parse_common_args()

plot_plan <- list(
  list(
    panel = "B",
    title = "q05 abundance Leiden niches",
    input = "panel_B_data.tsv",
    geometry = "point",
    x = "x",
    y = "y",
    colour = "spatial_niche",
    facet = "sample",
    output = "panel_B.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "C",
    title = "cell2location cell-state maps",
    input = "panel_C_data.tsv",
    geometry = "point",
    x = "x",
    y = "y",
    colour = "q05_abundance",
    facet = "cell_state",
    output = "panel_C.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "D",
    title = "Spatial Basal signature",
    input = "panel_D_data.tsv",
    geometry = "point",
    x = "x",
    y = "y",
    colour = "basal_score",
    facet = "sample",
    output = "panel_D.pdf",
    width = 5.5,
    height = 4.2
  )
)

if (length(plot_plan)) {
  run_figure_plots("SuppFig04", plot_plan, opts)
}

package_native_panels <- tibble::tibble(
  panel = character(), title = character(), workflow = character()
)

write_run_metadata(
  opts$output_dir,
  "SuppFig04_plot",
  opts,
  list(
    standard_vector_panels = length(plot_plan),
    package_native_panels = nrow(package_native_panels)
  )
)
