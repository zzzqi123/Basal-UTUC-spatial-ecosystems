#!/usr/bin/env Rscript

# Fig04 panel rendering.
# Standard panels are rendered from the exported tables below. Panels drawn
# directly by an analysis package are listed in package_native_panels.

source(file.path("core", "R", "cli.R"))
source(file.path("core", "R", "figure_assembly.R"))
opts <- parse_common_args()

plot_plan <- list(
  list(
    panel = "A",
    title = "Mesenchymal UMAP",
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
    title = "Mesenchymal pseudotime branches",
    input = "panel_B_data.tsv",
    geometry = "line",
    x = "pseudotime",
    y = "density",
    group = "cell_state",
    colour = "cell_state",
    output = "panel_B.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "D",
    title = "myCAF correlations with Basal and TGF-beta scores",
    input = "panel_D_data.tsv",
    geometry = "point",
    x = "x_value",
    y = "y_value",
    colour = "y_score",
    facet = "x_score",
    output = "panel_D.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "E",
    title = "Tip-cell correlations with myCAF and hypoxia",
    input = "panel_E_data.tsv",
    geometry = "point",
    x = "x_value",
    y = "y_value",
    colour = "y_score",
    facet = "x_score",
    output = "panel_E.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "F",
    title = "Stromal and endothelial spatial maps",
    input = "panel_F_data.tsv",
    geometry = "point",
    x = "x",
    y = "y",
    colour = "q05_abundance",
    facet = "cell_state",
    output = "panel_F.pdf",
    width = 5.5,
    height = 4.2
  )
)

if (length(plot_plan)) {
  run_figure_plots("Fig04", plot_plan, opts)
}

package_native_panels <- tibble::tribble(
  ~panel, ~title, ~workflow,
  "C", "CAF functional-state radar summary", "workflows/single_cell/07_pathway_activity.R"
)
readr::write_tsv(
  package_native_panels,
  file.path(opts$output_dir, "package_native_plot_manifest.tsv")
)

write_run_metadata(
  opts$output_dir,
  "Fig04_plot",
  opts,
  list(
    standard_vector_panels = length(plot_plan),
    package_native_panels = nrow(package_native_panels)
  )
)
