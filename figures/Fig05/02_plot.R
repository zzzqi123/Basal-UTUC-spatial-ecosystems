#!/usr/bin/env Rscript

# Fig05 panel rendering.
# Standard statistical panels are rendered from the exported tables below.
# Package-native graphs (CellChat, Seurat dot plots, inferCNV, SCENIC) remain
# identified explicitly instead of being replaced with a misleading generic plot.

source(file.path("core", "R", "cli.R"))
source(file.path("core", "R", "figure_assembly.R"))
opts <- parse_common_args()

plot_plan <- list(
  list(
    panel = "C",
    title = "Outgoing and incoming communication centrality",
    input = "panel_C_data.tsv",
    geometry = "point",
    x = "outgoing",
    y = "incoming",
    colour = "cell_state",
    output = "panel_C.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "G",
    title = "Selected ligand-receptor probabilities",
    input = "panel_G_data.tsv",
    geometry = "bar",
    x = "interaction",
    y = "probability",
    fill = "stage",
    output = "panel_G.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "H",
    title = "Stage-level communication summary",
    input = "panel_H_data.tsv",
    geometry = "heatmap",
    x = "stage",
    y = "pathway",
    fill = "total_probability",
    output = "panel_H.pdf",
    width = 5.5,
    height = 4.2
  )
)

if (length(plot_plan)) {
  run_figure_plots("Fig05", plot_plan, opts)
}

package_native_panels <- tibble::tribble(
  ~panel, ~title, ~workflow,
  "A", "Number of inferred interactions", "workflows/communication/01_cellchat.R",
  "B", "Aggregated interaction strength", "workflows/communication/01_cellchat.R",
  "D", "SPP1 signaling network by stage", "workflows/communication/01_cellchat.R",
  "E", "TGF-beta signaling network by stage", "workflows/communication/01_cellchat.R",
  "F", "VEGF signaling network by stage", "workflows/communication/01_cellchat.R"
)
readr::write_tsv(
  package_native_panels,
  file.path(opts$output_dir, "package_native_plot_manifest.tsv")
)

write_run_metadata(
  opts$output_dir,
  "Fig05_plot",
  opts,
  list(
    standard_vector_panels = length(plot_plan),
    package_native_panels = nrow(package_native_panels)
  )
)
