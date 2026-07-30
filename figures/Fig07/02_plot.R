#!/usr/bin/env Rscript

# Fig07 panel rendering.
# Standard statistical panels are rendered from the exported tables below.
# Package-native graphs (CellChat, Seurat dot plots, inferCNV, SCENIC) remain
# identified explicitly instead of being replaced with a misleading generic plot.

source(file.path("core", "R", "cli.R"))
source(file.path("core", "R", "figure_assembly.R"))
opts <- parse_common_args()

plot_plan <- list(
  list(
    panel = "A",
    title = "Visium HD RCTD embedding",
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
    panel = "B",
    title = "Visium HD inferred cell-type map",
    input = "panel_B_data.tsv",
    geometry = "point",
    x = "x",
    y = "y",
    colour = "cell_type",
    output = "panel_B.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "C",
    title = "External SPP1 TAM-myCAF score",
    input = "panel_C_data.tsv",
    geometry = "point",
    x = "x",
    y = "y",
    colour = "pair_score",
    output = "panel_C.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "D",
    title = "Basal, luminal and component maps",
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
    title = "GeoMx component-score correlation",
    input = "panel_E_data.tsv",
    geometry = "point",
    x = "spp1_tam_score",
    y = "fap_mycaf_score",
    colour = "region",
    output = "panel_E.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "F",
    title = "GeoMx cytotoxic-program associations",
    input = "panel_F_data.tsv",
    geometry = "bar",
    x = "program",
    y = "estimate",
    fill = "estimate",
    output = "panel_F.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "G",
    title = "GeoMx suppressive-program associations",
    input = "panel_G_data.tsv",
    geometry = "bar",
    x = "program",
    y = "estimate",
    fill = "estimate",
    output = "panel_G.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "H",
    title = "Paired Basal-high versus luminal-high comparison",
    input = "panel_H_data.tsv",
    geometry = "box",
    x = "region_group",
    y = "proportion",
    fill = "region_group",
    facet = "component",
    output = "panel_H.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "I",
    title = "Paired Visium validation maps",
    input = "panel_I_data.tsv",
    geometry = "point",
    x = "x",
    y = "y",
    colour = "value",
    facet = "feature",
    output = "panel_I.pdf",
    width = 5.5,
    height = 4.2
  )
)

if (length(plot_plan)) {
  run_figure_plots("Fig07", plot_plan, opts)
}

package_native_panels <- tibble::tibble(
  panel = character(), title = character(), workflow = character()
)

write_run_metadata(
  opts$output_dir,
  "Fig07_plot",
  opts,
  list(
    standard_vector_panels = length(plot_plan),
    package_native_panels = nrow(package_native_panels)
  )
)
