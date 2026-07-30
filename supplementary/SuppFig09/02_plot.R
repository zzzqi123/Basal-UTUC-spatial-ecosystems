#!/usr/bin/env Rscript

# SuppFig09 panel rendering.
# Standard statistical panels are rendered from the exported tables below.
# Package-native graphs (CellChat, Seurat dot plots, inferCNV, SCENIC) remain
# identified explicitly instead of being replaced with a misleading generic plot.

source(file.path("core", "R", "cli.R"))
source(file.path("core", "R", "figure_assembly.R"))
opts <- parse_common_args()

plot_plan <- list(
  list(
    panel = "A",
    title = "CD4 T-cell UMAP",
    input = "panel_A_data.tsv",
    geometry = "point",
    x = "UMAP_1",
    y = "UMAP_2",
    colour = "cell_state",
    output = "panel_A.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "B",
    title = "CD4 markers and functions",
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
    title = "CD4 relative enrichment",
    input = "panel_C_data.tsv",
    geometry = "heatmap",
    x = "sample_group",
    y = "cell_state",
    fill = "roe",
    output = "panel_C.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "D",
    title = "CD8 T-cell UMAP",
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
    panel = "E",
    title = "CD8 markers and functions",
    input = "panel_E_data.tsv",
    geometry = "heatmap",
    x = "cell_state",
    y = "gene_or_term",
    fill = "value",
    facet = "kind",
    output = "panel_E.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "F",
    title = "CD8 functional programs",
    input = "panel_F_data.tsv",
    geometry = "heatmap",
    x = "cell_state",
    y = "program",
    fill = "score",
    output = "panel_F.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "G",
    title = "B-cell DSS",
    input = "panel_G_data.tsv",
    geometry = "line",
    x = "time",
    y = "survival",
    group = "signature",
    colour = "signature",
    output = "panel_G.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "H",
    title = "Lymphoid-marker correlations",
    input = "panel_H_data.tsv",
    geometry = "heatmap",
    x = "signature",
    y = "marker",
    fill = "rho",
    output = "panel_H.pdf",
    width = 5.5,
    height = 4.2
  )
)

if (length(plot_plan)) {
  run_figure_plots("SuppFig09", plot_plan, opts)
}

package_native_panels <- tibble::tibble(
  panel = character(), title = character(), workflow = character()
)

write_run_metadata(
  opts$output_dir,
  "SuppFig09_plot",
  opts,
  list(
    standard_vector_panels = length(plot_plan),
    package_native_panels = nrow(package_native_panels)
  )
)
