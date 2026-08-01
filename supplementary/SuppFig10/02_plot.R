#!/usr/bin/env Rscript

# SuppFig10 panel rendering.
# Standard panels are rendered from the exported tables below. Panels drawn
# directly by an analysis package are listed in package_native_panels.

source(file.path("core", "R", "cli.R"))
source(file.path("core", "R", "figure_assembly.R"))
opts <- parse_common_args()

plot_plan <- list(
  list(
    panel = "A",
    title = "Mesenchymal markers and GO terms",
    input = "panel_A_data.tsv",
    geometry = "heatmap",
    x = "cell_state",
    y = "gene_or_term",
    fill = "value",
    facet = "kind",
    output = "panel_A.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "B",
    title = "Spatial myogenesis score",
    input = "panel_B_data.tsv",
    geometry = "point",
    x = "x",
    y = "y",
    colour = "myogenesis_score",
    output = "panel_B.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "C",
    title = "CAF_c3_FAP Hallmark enrichment",
    input = "panel_C_data.tsv",
    geometry = "bar",
    x = "pathway",
    y = "NES",
    fill = "NES",
    output = "panel_C.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "D",
    title = "Endothelial UMAP",
    input = "panel_D_data.tsv",
    geometry = "point",
    x = "UMAP_1",
    y = "UMAP_2",
    colour = "cell_state",
    output = "panel_D.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "F",
    title = "Endo_c1_CXCR4 enrichment",
    input = "panel_F_data.tsv",
    geometry = "bar",
    x = "pathway",
    y = "NES",
    fill = "NES",
    output = "panel_F.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "G",
    title = "Stromal and endothelial DSS",
    input = "panel_G_data.tsv",
    geometry = "line",
    x = "time",
    y = "survival",
    group = "signature",
    colour = "signature",
    output = "panel_G.pdf",
    width = 5.5,
    height = 4.2
  )
)

if (length(plot_plan)) {
  run_figure_plots("SuppFig10", plot_plan, opts)
}

package_native_panels <- tibble::tribble(
  ~panel, ~title, ~workflow,
  "E", "Endothelial marker dot plot", "workflows/single_cell/01b_annotation_and_markers.R -> workflows/single_cell/08_marker_visualization.R"
)
readr::write_tsv(
  package_native_panels,
  file.path(opts$output_dir, "package_native_plot_manifest.tsv")
)

write_run_metadata(
  opts$output_dir,
  "SuppFig10_plot",
  opts,
  list(
    standard_vector_panels = length(plot_plan),
    package_native_panels = nrow(package_native_panels)
  )
)
