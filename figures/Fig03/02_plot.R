#!/usr/bin/env Rscript

# Fig03 panel rendering.
# Standard statistical panels are rendered from the exported tables below.
# Package-native graphs (CellChat, Seurat dot plots, inferCNV, SCENIC) remain
# identified explicitly instead of being replaced with a misleading generic plot.

source(file.path("core", "R", "cli.R"))
source(file.path("core", "R", "figure_assembly.R"))
opts <- parse_common_args()

plot_plan <- list(
  list(
    panel = "A",
    title = "Myeloid UMAP",
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
    title = "Myeloid relative enrichment by tissue group",
    input = "panel_B_data.tsv",
    geometry = "heatmap",
    x = "sample_group",
    y = "cell_state",
    fill = "roe",
    output = "panel_B.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "C",
    title = "Monocyte-macrophage pseudotime",
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
    title = "CCR2 monocyte and SPP1 TAM spatial co-localization",
    input = "panel_D_data.tsv",
    geometry = "point",
    x = "x",
    y = "y",
    colour = "colocalization_score",
    facet = "pair_id",
    output = "panel_D.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "E",
    title = "Spatial TAM M2 signature",
    input = "panel_E_data.tsv",
    geometry = "point",
    x = "x",
    y = "y",
    colour = "m2_score",
    facet = "sample",
    output = "panel_E.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "F",
    title = "Neutrophil UMAP",
    input = "panel_F_data.tsv",
    geometry = "point",
    x = "UMAP_1",
    y = "UMAP_2",
    colour = "cell_state",
    output = "panel_F.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "G",
    title = "VEGFA TAN and Cancer_c3 spatial co-localization",
    input = "panel_G_data.tsv",
    geometry = "point",
    x = "x",
    y = "y",
    colour = "colocalization_score",
    facet = "pair_id",
    output = "panel_G.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "H",
    title = "Myeloid-state survival curves",
    input = "panel_H_data.tsv",
    geometry = "line",
    x = "time",
    y = "survival",
    group = "signature",
    colour = "signature",
    output = "panel_H.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "I",
    title = "Neu_c2_VEGFA Hallmark enrichment",
    input = "panel_I_data.tsv",
    geometry = "bar",
    x = "pathway",
    y = "NES",
    fill = "NES",
    output = "panel_I.pdf",
    width = 5.5,
    height = 4.2
  )
)

if (length(plot_plan)) {
  run_figure_plots("Fig03", plot_plan, opts)
}

package_native_panels <- tibble::tibble(
  panel = character(), title = character(), workflow = character()
)

write_run_metadata(
  opts$output_dir,
  "Fig03_plot",
  opts,
  list(
    standard_vector_panels = length(plot_plan),
    package_native_panels = nrow(package_native_panels)
  )
)
