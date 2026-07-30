#!/usr/bin/env Rscript

# SuppFig12 panel rendering.
# Standard statistical panels are rendered from the exported tables below.
# Package-native graphs (CellChat, Seurat dot plots, inferCNV, SCENIC) remain
# identified explicitly instead of being replaced with a misleading generic plot.

source(file.path("core", "R", "cli.R"))
source(file.path("core", "R", "figure_assembly.R"))
opts <- parse_common_args()

plot_plan <- list(
  list(
    panel = "A",
    title = "Major-lineage UMAP",
    input = "panel_A_data.tsv",
    geometry = "point",
    x = "UMAP_1",
    y = "UMAP_2",
    colour = "cell_type",
    output = "panel_A.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "D",
    title = "Myeloid reclustering and SPP1 density",
    input = "panel_D_data.tsv",
    geometry = "point",
    x = "UMAP_1",
    y = "UMAP_2",
    colour = "SPP1",
    output = "panel_D.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "E",
    title = "Fibroblast reclustering and FAP density",
    input = "panel_E_data.tsv",
    geometry = "point",
    x = "UMAP_1",
    y = "UMAP_2",
    colour = "FAP",
    output = "panel_E.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "F",
    title = "Endothelial reclustering and CXCR4 density",
    input = "panel_F_data.tsv",
    geometry = "point",
    x = "UMAP_1",
    y = "UMAP_2",
    colour = "CXCR4",
    output = "panel_F.pdf",
    width = 5.5,
    height = 4.2
  )
)

if (length(plot_plan)) {
  run_figure_plots("SuppFig12", plot_plan, opts)
}

package_native_panels <- tibble::tribble(
  ~panel, ~title, ~workflow,
  "B", "Canonical lineage-marker dot plot", "workflows/single_cell/01b_annotation_and_markers.R -> workflows/single_cell/08_marker_visualization.R",
  "C", "Neutrophil-marker audit", "workflows/single_cell/01b_annotation_and_markers.R -> workflows/single_cell/08_marker_visualization.R"
)
readr::write_tsv(
  package_native_panels,
  file.path(opts$output_dir, "package_native_plot_manifest.tsv")
)

write_run_metadata(
  opts$output_dir,
  "SuppFig12_plot",
  opts,
  list(
    standard_vector_panels = length(plot_plan),
    package_native_panels = nrow(package_native_panels)
  )
)
