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
    panel = "E",
    title = "TGFB1-(TGFBR1+TGFBR2) spatial signal",
    input = "panel_E_data.tsv",
    geometry = "point",
    x = "x",
    y = "y",
    colour = "interaction_score",
    facet = "sample",
    output = "panel_E.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "F",
    title = "SPP1-(ITGA8+ITGB1) spatial signal",
    input = "panel_F_data.tsv",
    geometry = "point",
    x = "x",
    y = "y",
    colour = "interaction_score",
    facet = "sample",
    output = "panel_F.pdf",
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
  "D", "Selected SPP1 TAM-myCAF ligand-receptor probabilities", "workflows/communication/01_cellchat.R",
  "G", "NMI-Basal SPP1 and TGF-beta spatial communication", "workflows/communication/03_cellchat_spatial.R",
  "H", "MI-Basal SPP1 and TGF-beta spatial communication", "workflows/communication/03_cellchat_spatial.R"
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
