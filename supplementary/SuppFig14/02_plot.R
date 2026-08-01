#!/usr/bin/env Rscript

# SuppFig14 panel rendering.
# Standard panels are rendered from the exported tables below. Panels drawn
# directly by an analysis package are listed in package_native_panels.

source(file.path("core", "R", "cli.R"))
source(file.path("core", "R", "figure_assembly.R"))
opts <- parse_common_args()

plot_plan <- list(
  list(
    panel = "A",
    title = "Signed distance from the inferred tumor boundary",
    input = "panel_A_data.tsv",
    geometry = "point",
    x = "x",
    y = "y",
    colour = "signed_distance",
    facet = "sample",
    output = "panel_A.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "C",
    title = "Adjusted spatial niche-pathway associations in MI sections",
    input = "panel_C_data.tsv",
    geometry = "forest",
    effect = "beta",
    term = "pathway",
    lower = "CI_low",
    upper = "CI_high",
    facet = "niche",
    output = "panel_C.pdf",
    width = 5.5,
    height = 4.2
  )
)

if (length(plot_plan)) {
  run_figure_plots("SuppFig14", plot_plan, opts)
}

package_native_panels <- tibble::tribble(
  ~panel, ~title, ~workflow,
  "B", "Integrated Hallmark GSEA for each spatial niche", "workflows/spatial/14_niche_functional_analysis.R"
)
readr::write_tsv(
  package_native_panels,
  file.path(opts$output_dir, "package_native_plot_manifest.tsv")
)

write_run_metadata(
  opts$output_dir,
  "SuppFig14_plot",
  opts,
  list(
    standard_vector_panels = length(plot_plan),
    package_native_panels = nrow(package_native_panels)
  )
)
