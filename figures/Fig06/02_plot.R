#!/usr/bin/env Rscript

# Fig06 panel rendering.
# Standard statistical panels are rendered from the exported tables below.
# Package-native graphs (CellChat, Seurat dot plots, inferCNV, SCENIC) remain
# identified explicitly instead of being replaced with a misleading generic plot.

source(file.path("core", "R", "cli.R"))
source(file.path("core", "R", "figure_assembly.R"))
opts <- parse_common_args()

plot_plan <- list(
  list(
    panel = "A",
    title = "NMI-Basal spatial co-localization",
    input = "panel_A_data.tsv",
    geometry = "point",
    x = "x",
    y = "y",
    colour = "q05_abundance",
    facet = "component",
    output = "panel_A.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "B",
    title = "MI-Basal spatial co-localization",
    input = "panel_B_data.tsv",
    geometry = "point",
    x = "x",
    y = "y",
    colour = "q05_abundance",
    facet = "component",
    output = "panel_B.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "E",
    title = "TGF-beta ligand-receptor spatial signal",
    input = "panel_E_data.tsv",
    geometry = "point",
    x = "x",
    y = "y",
    colour = "interaction_score",
    output = "panel_E.pdf",
    width = 5.5,
    height = 4.2
  ),
  list(
    panel = "F",
    title = "SPP1-integrin spatial signal",
    input = "panel_F_data.tsv",
    geometry = "point",
    x = "x",
    y = "y",
    colour = "interaction_score",
    output = "panel_F.pdf",
    width = 5.5,
    height = 4.2
  )
)

if (length(plot_plan)) {
  run_figure_plots("Fig06", plot_plan, opts)
}

package_native_panels <- tibble::tribble(
  ~panel, ~title, ~workflow,
  "D", "NicheNet multi-ligand candidate network", "workflows/communication/02_nichenet_tam_to_mycaf.R"
)
readr::write_tsv(
  package_native_panels,
  file.path(opts$output_dir, "package_native_plot_manifest.tsv")
)

write_run_metadata(
  opts$output_dir,
  "Fig06_plot",
  opts,
  list(
    standard_vector_panels = length(plot_plan),
    package_native_panels = nrow(package_native_panels)
  )
)
