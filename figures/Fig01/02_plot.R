#!/usr/bin/env Rscript

# Fig01 panel rendering.
# Standard statistical panels are rendered from the exported tables below.
# Package-native graphs (CellChat, Seurat dot plots, inferCNV, SCENIC) remain
# identified explicitly instead of being replaced with a misleading generic plot.

source(file.path("core", "R", "cli.R"))
source(file.path("core", "R", "figure_assembly.R"))
opts <- parse_common_args()

plot_plan <- list(
  list(
    panel = "A",
    title = "Molecular subtype distribution by stage",
    input = "panel_A_data.tsv",
    geometry = "bar",
    x = "stage",
    y = "proportion",
    fill = "subtype",
    output = "panel_A.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "B",
    title = "Subtype-stratified disease-specific survival",
    input = "panel_B_data.tsv",
    geometry = "line",
    x = "time",
    y = "survival",
    group = "subtype",
    colour = "subtype",
    facet = "endpoint",
    output = "panel_B.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "C",
    title = "Immune and stromal scores within stage",
    input = "panel_C_data.tsv",
    geometry = "box",
    x = "subtype",
    y = "score_value",
    fill = "subtype",
    facet = "score_name",
    output = "panel_C.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "D",
    title = "Single-cell UMAP of major lineages",
    input = "panel_D_data.tsv",
    geometry = "point",
    x = "UMAP_1",
    y = "UMAP_2",
    colour = "major_celltype",
    output = "panel_D.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "F",
    title = "Relative enrichment of major cell types",
    input = "panel_F_data.tsv",
    geometry = "heatmap",
    x = "sample_group",
    y = "cell_type",
    fill = "roe",
    output = "panel_F.pdf",
    width = 5.5,
    height = 4.2
  )
)

if (length(plot_plan)) {
  run_figure_plots("Fig01", plot_plan, opts)
}

package_native_panels <- tibble::tribble(
  ~panel, ~title, ~workflow,
  "E", "Representative lineage-marker dot plot", "workflows/single_cell/01b_annotation_and_markers.R -> workflows/single_cell/08_marker_visualization.R"
)
readr::write_tsv(
  package_native_panels,
  file.path(opts$output_dir, "package_native_plot_manifest.tsv")
)

write_run_metadata(
  opts$output_dir,
  "Fig01_plot",
  opts,
  list(
    standard_vector_panels = length(plot_plan),
    package_native_panels = nrow(package_native_panels)
  )
)
