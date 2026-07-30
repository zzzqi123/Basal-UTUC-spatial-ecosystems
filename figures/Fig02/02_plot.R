#!/usr/bin/env Rscript

# Fig02 panel rendering.
# Standard statistical panels are rendered from the exported tables below.
# Package-native graphs (CellChat, Seurat dot plots, inferCNV, SCENIC) remain
# identified explicitly instead of being replaced with a misleading generic plot.

source(file.path("core", "R", "cli.R"))
source(file.path("core", "R", "figure_assembly.R"))
opts <- parse_common_args()

plot_plan <- list(
  list(
    panel = "A",
    title = "cell2location major-cell-type maps",
    input = "panel_A_data.tsv",
    geometry = "point",
    x = "x",
    y = "y",
    colour = "q05_abundance",
    facet = "cell_type",
    output = "panel_A.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "B",
    title = "Within-section cell-state correlations",
    input = "panel_B_data.tsv",
    geometry = "heatmap",
    x = "state_1",
    y = "state_2",
    fill = "spearman_rho",
    facet = "sample",
    output = "panel_B.pdf",
    width = 5.5,
    height = 4.2
  )
)

if (length(plot_plan)) {
  run_figure_plots("Fig02", plot_plan, opts)
}

package_native_panels <- tibble::tibble(
  panel = character(), title = character(), workflow = character()
)

write_run_metadata(
  opts$output_dir,
  "Fig02_plot",
  opts,
  list(
    standard_vector_panels = length(plot_plan),
    package_native_panels = nrow(package_native_panels)
  )
)
