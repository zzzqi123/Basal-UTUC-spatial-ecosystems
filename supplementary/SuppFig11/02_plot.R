#!/usr/bin/env Rscript

# SuppFig11 panel rendering.
# Standard statistical panels are rendered from the exported tables below.
# Package-native graphs (CellChat, Seurat dot plots, inferCNV, SCENIC) remain
# identified explicitly instead of being replaced with a misleading generic plot.

source(file.path("core", "R", "cli.R"))
source(file.path("core", "R", "figure_assembly.R"))
opts <- parse_common_args()

plot_plan <- list(
  list(
    panel = "A",
    title = "Immune and stromal scores",
    input = "panel_A_data.tsv",
    geometry = "box",
    x = "subtype",
    y = "score_value",
    fill = "subtype",
    facet = "score_name",
    output = "panel_A.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "B",
    title = "FAP and SPP1 expression",
    input = "panel_B_data.tsv",
    geometry = "box",
    x = "subtype",
    y = "expression",
    fill = "subtype",
    facet = "gene",
    output = "panel_B.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "C",
    title = "SPP1 correlations",
    input = "panel_C_data.tsv",
    geometry = "point",
    x = "SPP1",
    y = "score_value",
    facet = "score_name",
    output = "panel_C.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "D",
    title = "Subtype-classification ROC",
    input = "panel_D_data.tsv",
    geometry = "line",
    x = "fpr",
    y = "tpr",
    group = "marker",
    colour = "marker",
    output = "panel_D.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "E",
    title = "External survival validation",
    input = "panel_E_data.tsv",
    geometry = "line",
    x = "time",
    y = "survival",
    group = "group",
    colour = "group",
    facet = "dataset",
    output = "panel_E.pdf",
    width = 5.5,
    height = 4.2
  )
)

if (length(plot_plan)) {
  run_figure_plots("SuppFig11", plot_plan, opts)
}

package_native_panels <- tibble::tibble(
  panel = character(), title = character(), workflow = character()
)

write_run_metadata(
  opts$output_dir,
  "SuppFig11_plot",
  opts,
  list(
    standard_vector_panels = length(plot_plan),
    package_native_panels = nrow(package_native_panels)
  )
)
