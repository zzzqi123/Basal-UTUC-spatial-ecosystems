#!/usr/bin/env Rscript

# SuppFig05 panel rendering.
# Standard panels are rendered from the exported tables below. Panels drawn
# directly by an analysis package are listed in package_native_panels.

source(file.path("core", "R", "cli.R"))
source(file.path("core", "R", "figure_assembly.R"))
opts <- parse_common_args()

plot_plan <- list(
  list(
    panel = "B",
    title = "Malignant epithelial UMAP",
    input = "panel_B_data.tsv",
    geometry = "point",
    x = "UMAP_1",
    y = "UMAP_2",
    colour = "cell_state",
    output = "panel_B.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "C",
    title = "CytoTRACE2 and Monocle3 trajectories",
    input = "panel_C_data.tsv",
    geometry = "point",
    x = "embedding_1",
    y = "embedding_2",
    colour = "value",
    facet = "analysis",
    output = "panel_C.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "D",
    title = "Basal-marker density",
    input = "panel_D_data.tsv",
    geometry = "point",
    x = "UMAP_1",
    y = "UMAP_2",
    colour = "expression",
    facet = "gene",
    output = "panel_D.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "E",
    title = "Malignant-state spatial maps",
    input = "panel_E_data.tsv",
    geometry = "point",
    x = "x",
    y = "y",
    colour = "q05_abundance",
    facet = "cell_state",
    output = "panel_E.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "F",
    title = "Cancer_c0 and Cancer_c3 niche distribution",
    input = "panel_F_data.tsv",
    geometry = "heatmap",
    x = "spatial_niche",
    y = "cell_state",
    fill = "median_abundance",
    facet = "sample",
    output = "panel_F.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "G",
    title = "Cancer_c0 and Cancer_c3 DSS",
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
    title = "Top malignant regulons",
    input = "panel_H_data.tsv",
    geometry = "heatmap",
    x = "cell_state",
    y = "regulon",
    fill = "auc",
    output = "panel_H.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "I",
    title = "Cancer_c0 enrichment",
    input = "panel_I_data.tsv",
    geometry = "bar",
    x = "pathway",
    y = "NES",
    fill = "NES",
    output = "panel_I.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "J",
    title = "PROGENy activity",
    input = "panel_J_data.tsv",
    geometry = "heatmap",
    x = "cell_state",
    y = "pathway",
    fill = "activity",
    output = "panel_J.pdf",
    width = 5.5,
    height = 4.2
  )
)

if (length(plot_plan)) {
  run_figure_plots("SuppFig05", plot_plan, opts)
}

package_native_panels <- tibble::tribble(
  ~panel, ~title, ~workflow,
  "A", "Adjacent-epithelial-reference inferCNV heatmap", "workflows/single_cell/02a_infercnv_adjacent_epithelial_reference.R"
)
readr::write_tsv(
  package_native_panels,
  file.path(opts$output_dir, "package_native_plot_manifest.tsv")
)

write_run_metadata(
  opts$output_dir,
  "SuppFig05_plot",
  opts,
  list(
    standard_vector_panels = length(plot_plan),
    package_native_panels = nrow(package_native_panels)
  )
)
