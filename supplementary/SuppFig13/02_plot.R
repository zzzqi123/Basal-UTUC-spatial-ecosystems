#!/usr/bin/env Rscript

# SuppFig13 panel rendering.
# Standard statistical panels are rendered from the exported tables below.
# Package-native graphs (CellChat, Seurat dot plots, inferCNV, SCENIC) remain
# identified explicitly instead of being replaced with a misleading generic plot.

source(file.path("core", "R", "cli.R"))
source(file.path("core", "R", "figure_assembly.R"))
opts <- parse_common_args()

plot_plan <- list(
  list(
    panel = "C",
    title = "Cell-level CNV burden percentile concordance",
    input = "panel_C_data.tsv",
    geometry = "point",
    x = "primary_percentile",
    y = "sensitivity_percentile",
    colour = "sample",
    output = "panel_C.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "D",
    title = "Patient-specific CNV burden rank correlations",
    input = "panel_D_data.tsv",
    geometry = "bar",
    x = "sample",
    y = "spearman_rho",
    fill = "spearman_rho",
    output = "panel_D.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "E",
    title = "Original and revised malignant-subcluster UMAPs",
    input = "panel_E_data.tsv",
    geometry = "point",
    x = "UMAP_1",
    y = "UMAP_2",
    colour = "cell_state",
    facet = "analysis",
    output = "panel_E.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "G",
    title = "Malignant-subcluster marker-profile concordance",
    input = "panel_G_data.tsv",
    geometry = "heatmap",
    x = "primary_cluster",
    y = "sensitivity_cluster",
    fill = "spearman_rho",
    output = "panel_G.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "H",
    title = "Cancer_c0 and Cancer_c3 Hallmark NES concordance",
    input = "panel_H_data.tsv",
    geometry = "point",
    x = "primary_NES",
    y = "sensitivity_NES",
    colour = "cell_state",
    output = "panel_H.pdf",
    width = 5.5,
    height = 4.2
  )
)

if (length(plot_plan)) {
  run_figure_plots("SuppFig13", plot_plan, opts)
}

package_native_panels <- tibble::tribble(
  ~panel, ~title, ~workflow,
  "A", "Original adjacent-epithelial-reference inferCNV heatmap", "workflows/single_cell/02a_infercnv_adjacent_epithelial_reference.R",
  "B", "Within-sample non-epithelial-reference inferCNV heatmap", "workflows/single_cell/02_infercnv_non_epi_reference.R",
  "F", "Overlap of malignant cells under both references", "workflows/single_cell/02b_infercnv_reference_robustness.R"
)
readr::write_tsv(
  package_native_panels,
  file.path(opts$output_dir, "package_native_plot_manifest.tsv")
)

write_run_metadata(
  opts$output_dir,
  "SuppFig13_plot",
  opts,
  list(
    standard_vector_panels = length(plot_plan),
    package_native_panels = nrow(package_native_panels)
  )
)
