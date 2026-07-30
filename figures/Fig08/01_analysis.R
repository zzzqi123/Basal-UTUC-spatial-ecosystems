#!/usr/bin/env Rscript

# Fig08: Epithelial-intrinsic SPP1 perturbation and functional validation
# Heavy model fitting is performed by the named workflows. This script exposes
# the exact panel hand-off, validates de-identified table schemas, and writes
# one analysis table per computational panel.

source(file.path("core", "R", "cli.R"))
source(file.path("core", "R", "figure_assembly.R"))
opts <- parse_common_args()
set.seed(opts$seed)

panel_plan <- list(
  list(
    panel = "A",
    title = "Malignant-epithelial virtual-knockout enrichment",
    workflow = "workflows/perturbation/01_spp1_virtual_knockout.R",
    operation = "select",
    input = "Fig08_A.tsv",
    required = c("pathway", "NES", "FDR"),
    output = "panel_A_data.tsv"
  ),
  list(
    panel = "B",
    title = "SPP1 siRNA qRT-PCR",
    workflow = "non-computational source panel; code not applicable",
    operation = "document_only"
  ),
  list(
    panel = "C",
    title = "SPP1 knockdown western blot",
    workflow = "non-computational source panel; code not applicable",
    operation = "document_only"
  ),
  list(
    panel = "D",
    title = "J82 cell-viability assay",
    workflow = "non-computational source panel; code not applicable",
    operation = "document_only"
  ),
  list(
    panel = "E",
    title = "Transwell migration and invasion",
    workflow = "non-computational source panel; code not applicable",
    operation = "document_only"
  ),
  list(
    panel = "F",
    title = "Conditioned-medium tube-formation workflow",
    workflow = "non-computational source panel; code not applicable",
    operation = "document_only"
  ),
  list(
    panel = "G",
    title = "HUVEC tube-formation images and quantification",
    workflow = "non-computational source panel; code not applicable",
    operation = "document_only"
  )
)

audit <- run_figure_analysis("Fig08", panel_plan, opts)
write_run_metadata(
  opts$output_dir,
  "Fig08_analysis",
  opts,
  list(
    computational_panels = sum(audit$status == "written"),
    documented_noncomputational_panels =
      sum(audit$status == "documented_noncomputational_panel")
  )
)
