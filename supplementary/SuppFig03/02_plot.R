#!/usr/bin/env Rscript

# SuppFig03 panel rendering.
# Standard statistical panels are rendered from the exported tables below.
# Package-native graphs (CellChat, Seurat dot plots, inferCNV, SCENIC) remain
# identified explicitly instead of being replaced with a misleading generic plot.

source(file.path("core", "R", "cli.R"))
source(file.path("core", "R", "figure_assembly.R"))
opts <- parse_common_args()

plot_plan <- list(
  list(
    panel = "A",
    title = "Annotated single-cell t-SNE",
    input = "panel_A_data.tsv",
    geometry = "point",
    x = "tSNE_1",
    y = "tSNE_2",
    colour = "cell_type",
    output = "panel_A.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "B",
    title = "Cell-level scPagwas adjusted FDR",
    input = "panel_B_data.tsv",
    geometry = "point",
    x = "tSNE_1",
    y = "tSNE_2",
    colour = "Random_Correct_BG_adjp",
    output = "panel_B.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "C",
    title = "Cell-type scPagwas bootstrap FDR",
    input = "panel_C_data.tsv",
    geometry = "bar",
    x = "cell_type",
    y = "celltype_FDR",
    fill = "celltype_FDR",
    output = "panel_C.pdf",
    width = 5.5,
    height = 4.2
  )
)

if (length(plot_plan)) {
  run_figure_plots("SuppFig03", plot_plan, opts)
}

package_native_panels <- tibble::tibble(
  panel = character(), title = character(), workflow = character()
)

write_run_metadata(
  opts$output_dir,
  "SuppFig03_plot",
  opts,
  list(
    standard_vector_panels = length(plot_plan),
    package_native_panels = nrow(package_native_panels)
  )
)
