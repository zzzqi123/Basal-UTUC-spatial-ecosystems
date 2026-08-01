#!/usr/bin/env Rscript

# SuppFig07 panel rendering.
# Standard panels are rendered from the exported tables below. Panels drawn
# directly by an analysis package are listed in package_native_panels.

source(file.path("core", "R", "cli.R"))
source(file.path("core", "R", "figure_assembly.R"))
opts <- parse_common_args()

plot_plan <- list(
  list(
    panel = "B",
    title = "Markers and GO terms",
    input = "panel_B_data.tsv",
    geometry = "heatmap",
    x = "cell_state",
    y = "gene_or_term",
    fill = "value",
    facet = "kind",
    output = "panel_B.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "C",
    title = "Subcluster density along pseudotime",
    input = "panel_C_data.tsv",
    geometry = "line",
    x = "pseudotime",
    y = "density",
    group = "cell_state",
    colour = "cell_state",
    output = "panel_C.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "D",
    title = "CCR2-SPP1 co-localization and M2 spatial scores",
    input = "panel_D_data.tsv",
    geometry = "point",
    x = "x",
    y = "y",
    colour = "value",
    facet = "feature",
    output = "panel_D.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "E",
    title = "Dendritic-cell DSS",
    input = "panel_E_data.tsv",
    geometry = "line",
    x = "time",
    y = "survival",
    group = "signature",
    colour = "signature",
    output = "panel_E.pdf",
    width = 5.5,
    height = 4.2
  )
)

if (length(plot_plan)) {
  run_figure_plots("SuppFig07", plot_plan, opts)
}

package_native_panels <- tibble::tribble(
  ~panel, ~title, ~workflow,
  "A", "Canonical marker dot plot", "workflows/single_cell/01b_annotation_and_markers.R -> workflows/single_cell/08_marker_visualization.R"
)
readr::write_tsv(
  package_native_panels,
  file.path(opts$output_dir, "package_native_plot_manifest.tsv")
)

write_run_metadata(
  opts$output_dir,
  "SuppFig07_plot",
  opts,
  list(
    standard_vector_panels = length(plot_plan),
    package_native_panels = nrow(package_native_panels)
  )
)
