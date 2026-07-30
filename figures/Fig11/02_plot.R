#!/usr/bin/env Rscript

# Fig11 panel rendering.
# Standard statistical panels are rendered from the exported tables below.
# Package-native graphs (CellChat, Seurat dot plots, inferCNV, SCENIC) remain
# identified explicitly instead of being replaced with a misleading generic plot.

source(file.path("core", "R", "cli.R"))
source(file.path("core", "R", "figure_assembly.R"))
opts <- parse_common_args()

plot_plan <- list(
  list(
    panel = "A",
    title = "DSS in Basal NMI versus Basal MI",
    input = "panel_A_data.tsv",
    geometry = "line",
    x = "time",
    y = "survival",
    group = "stage",
    colour = "stage",
    output = "panel_A.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "B",
    title = "SPP1 and FAP correlations with Basal score",
    input = "panel_B_data.tsv",
    geometry = "point",
    x = "expression",
    y = "basal_score",
    colour = "gene",
    facet = "gene",
    output = "panel_B.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "C",
    title = "Subtype-classification ROC curves",
    input = "panel_C_data.tsv",
    geometry = "line",
    x = "fpr",
    y = "tpr",
    group = "marker",
    colour = "marker",
    output = "panel_C.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "D",
    title = "Joint SPP1-FAP survival stratification",
    input = "panel_D_data.tsv",
    geometry = "line",
    x = "time",
    y = "survival",
    group = "group",
    colour = "group",
    output = "panel_D.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "E",
    title = "Time-dependent DSS AUC",
    input = "panel_E_data.tsv",
    geometry = "line",
    x = "year",
    y = "auc",
    group = "model",
    colour = "model",
    output = "panel_E.pdf",
    width = 5.5,
    height = 4.2
  )
)

if (length(plot_plan)) {
  run_figure_plots("Fig11", plot_plan, opts)
}

package_native_panels <- tibble::tibble(
  panel = character(), title = character(), workflow = character()
)

write_run_metadata(
  opts$output_dir,
  "Fig11_plot",
  opts,
  list(
    standard_vector_panels = length(plot_plan),
    package_native_panels = nrow(package_native_panels)
  )
)
