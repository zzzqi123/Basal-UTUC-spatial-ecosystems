#!/usr/bin/env Rscript

# SuppFig02 panel rendering.
# Standard panels are rendered from the exported tables below. Panels drawn
# directly by an analysis package are listed in package_native_panels.

source(file.path("core", "R", "cli.R"))
source(file.path("core", "R", "figure_assembly.R"))
opts <- parse_common_args()

plot_plan <- list(
  list(
    panel = "A",
    title = "Single-cell quality-control metrics",
    input = "panel_A_data.tsv",
    geometry = "box",
    x = "sample",
    y = "value",
    fill = "sample",
    facet = "metric",
    output = "panel_A.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "B",
    title = "Lineage-marker density maps",
    input = "panel_B_data.tsv",
    geometry = "point",
    x = "UMAP_1",
    y = "UMAP_2",
    colour = "expression",
    facet = "gene",
    output = "panel_B.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "C",
    title = "Major-cell-type proportions",
    input = "panel_C_data.tsv",
    geometry = "bar",
    x = "sample_group",
    y = "proportion",
    fill = "cell_type",
    output = "panel_C.pdf",
    width = 5.5,
    height = 4.2
  )
)

if (length(plot_plan)) {
  run_figure_plots("SuppFig02", plot_plan, opts)
}

package_native_panels <- tibble::tibble(
  panel = character(), title = character(), workflow = character()
)

write_run_metadata(
  opts$output_dir,
  "SuppFig02_plot",
  opts,
  list(
    standard_vector_panels = length(plot_plan),
    package_native_panels = nrow(package_native_panels)
  )
)
