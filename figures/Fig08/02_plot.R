#!/usr/bin/env Rscript

# Fig08 panel rendering.
# Standard statistical panels are rendered from the exported tables below.
# Package-native graphs (CellChat, Seurat dot plots, inferCNV, SCENIC) remain
# identified explicitly instead of being replaced with a misleading generic plot.

source(file.path("core", "R", "cli.R"))
source(file.path("core", "R", "figure_assembly.R"))
opts <- parse_common_args()

plot_plan <- list(
  list(
    panel = "A",
    title = "SPP1 expression in adjacent and malignant epithelial cells",
    input = "panel_A_data.tsv",
    geometry = "point",
    x = "UMAP_1",
    y = "UMAP_2",
    colour = "SPP1",
    facet = "tissue_group",
    output = "panel_A.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "B",
    title = "Malignant-epithelial virtual-knockout enrichment",
    input = "panel_B_data.tsv",
    geometry = "bar",
    x = "pathway",
    y = "neg_log10_FDR",
    fill = "ontology",
    output = "panel_B.pdf",
    width = 5.5,
    height = 4.2
  )
)

if (length(plot_plan)) {
  run_figure_plots("Fig08", plot_plan, opts)
}

package_native_panels <- tibble::tibble(
  panel = character(), title = character(), workflow = character()
)

write_run_metadata(
  opts$output_dir,
  "Fig08_plot",
  opts,
  list(
    standard_vector_panels = length(plot_plan),
    package_native_panels = nrow(package_native_panels)
  )
)
