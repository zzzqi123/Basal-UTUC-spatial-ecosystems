#!/usr/bin/env Rscript

# SuppFig01 panel rendering.
# Standard statistical panels are rendered from the exported tables below.
# Package-native graphs (CellChat, Seurat dot plots, inferCNV, SCENIC) remain
# identified explicitly instead of being replaced with a misleading generic plot.

source(file.path("core", "R", "cli.R"))
source(file.path("core", "R", "figure_assembly.R"))
opts <- parse_common_args()

plot_plan <- list(
  list(
    panel = "A",
    title = "Subtype distribution across stages",
    input = "panel_A_data.tsv",
    geometry = "bar",
    x = "stage",
    y = "proportion",
    fill = "subtype",
    output = "panel_A.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "B",
    title = "Tumor purity within stage",
    input = "panel_B_data.tsv",
    geometry = "box",
    x = "subtype",
    y = "purity",
    fill = "subtype",
    facet = "stage",
    output = "panel_B.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "C",
    title = "Immune, myeloid and stromal marker expression",
    input = "panel_C_data.tsv",
    geometry = "box",
    x = "subtype",
    y = "expression",
    fill = "subtype",
    facet = "gene",
    output = "panel_C.pdf",
    width = 5.5,
    height = 4.2
  )
)

if (length(plot_plan)) {
  run_figure_plots("SuppFig01", plot_plan, opts)
}

package_native_panels <- tibble::tribble(
  ~panel, ~title, ~workflow,
  "D", "Major-cell-type Sankey summary", "workflows/single_cell/01_process_scrna.R"
)
readr::write_tsv(
  package_native_panels,
  file.path(opts$output_dir, "package_native_plot_manifest.tsv")
)

write_run_metadata(
  opts$output_dir,
  "SuppFig01_plot",
  opts,
  list(
    standard_vector_panels = length(plot_plan),
    package_native_panels = nrow(package_native_panels)
  )
)
