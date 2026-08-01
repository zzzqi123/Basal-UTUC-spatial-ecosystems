#!/usr/bin/env Rscript

# Fig08: Epithelial SPP1 expression and functional effects of SPP1 knockdown in a urothelial carcinoma model
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
    title = "SPP1 expression in adjacent and malignant epithelial cells",
    workflow = "workflows/single_cell/01b_annotation_and_markers.R -> workflows/single_cell/08_marker_visualization.R",
    operation = "select",
    input = "Fig08_A.tsv",
    required = c("UMAP_1", "UMAP_2", "tissue_group", "SPP1"),
    output = "panel_A_data.tsv"
  ),
  list(
    panel = "B",
    title = "Malignant-epithelial virtual-knockout enrichment",
    workflow = "workflows/single_cell/10_spp1_virtual_knockout.R",
    operation = "select",
    input = "Fig08_B.tsv",
    required = c("pathway", "ontology", "gene_count", "FDR", "neg_log10_FDR"),
    output = "panel_B_data.tsv"
  ),
  list(
    panel = "C",
    title = "SPP1 siRNA qRT-PCR",
    workflow = "non-computational source panel; code not applicable",
    operation = "document_only"
  ),
  list(
    panel = "D",
    title = "SPP1 knockdown western blot",
    workflow = "non-computational source panel; code not applicable",
    operation = "document_only"
  ),
  list(
    panel = "E",
    title = "J82 cell-viability assay",
    workflow = "non-computational source panel; code not applicable",
    operation = "document_only"
  ),
  list(
    panel = "F",
    title = "Transwell migration and invasion",
    workflow = "non-computational source panel; code not applicable",
    operation = "document_only"
  ),
  list(
    panel = "G",
    title = "Conditioned-medium HUVEC tube-formation assay",
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
