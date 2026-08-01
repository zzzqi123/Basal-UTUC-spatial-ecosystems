#!/usr/bin/env Rscript

# SuppFig06 panel rendering.
# Standard statistical panels are rendered from the exported tables below.
# Package-native graphs (CellChat, Seurat dot plots, inferCNV, SCENIC) remain
# identified explicitly instead of being replaced with a misleading generic plot.

source(file.path("core", "R", "cli.R"))
source(file.path("core", "R", "figure_assembly.R"))
opts <- parse_common_args()

plot_plan <- list(
  list(
    panel = "A",
    title = "Top markers and GO terms",
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
    panel = "C",
    title = "Monocle3 robustness embeddings",
    input = "panel_C_data.tsv",
    geometry = "point",
    x = "embedding_1",
    y = "embedding_2",
    colour = "pseudotime",
    facet = "embedding",
    output = "panel_C.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "D",
    title = "Representative regulon activities",
    input = "panel_D_data.tsv",
    geometry = "box",
    x = "cell_state",
    y = "auc",
    fill = "cell_state",
    facet = "regulon",
    output = "panel_D.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "E",
    title = "Cancer_c3 Hallmark enrichment",
    input = "panel_E_data.tsv",
    geometry = "bar",
    x = "pathway",
    y = "NES",
    fill = "NES",
    output = "panel_E.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "F",
    title = "Section-specific Cancer_c3 boundary profiles",
    input = "panel_F_data.tsv",
    geometry = "line",
    x = "signed_distance",
    y = "fitted_z",
    group = "sample",
    colour = "sample",
    output = "panel_F.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "G",
    title = "Malignant programs along the external Basal-luminal continuum",
    input = "panel_G_data.tsv",
    geometry = "line",
    x = "basal_luminal_percentile",
    y = "mean_curve",
    group = "cell_state",
    colour = "cell_state",
    output = "panel_G.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "H",
    title = "Japan-UTUC Cancer_c3 muscle-invasion models",
    input = "panel_H_data.tsv",
    geometry = "forest",
    effect = "effect",
    term = "model",
    lower = "CI_low",
    upper = "CI_high",
    output = "panel_H.pdf",
    width = 5.5,
    height = 4.2
  )
)

if (length(plot_plan)) {
  run_figure_plots("SuppFig06", plot_plan, opts)
}

package_native_panels <- tibble::tribble(
  ~panel, ~title, ~workflow,
  "B", "Monocle2 DDRTree malignant trajectory", "workflows/single_cell/03_trajectory_analysis.R"
)
readr::write_tsv(
  package_native_panels,
  file.path(opts$output_dir, "package_native_plot_manifest.tsv")
)

write_run_metadata(
  opts$output_dir,
  "SuppFig06_plot",
  opts,
  list(
    standard_vector_panels = length(plot_plan),
    package_native_panels = nrow(package_native_panels)
  )
)
