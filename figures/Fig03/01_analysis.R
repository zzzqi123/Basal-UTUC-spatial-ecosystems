#!/usr/bin/env Rscript

# Fig03: Stage-associated remodeling of the myeloid compartment
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
    title = "Myeloid UMAP",
    workflow = "workflows/single_cell/01_process_scrna.R",
    operation = "select",
    input = "Fig03_A.tsv",
    required = c("UMAP_1", "UMAP_2", "cell_state"),
    output = "panel_A_data.tsv"
  ),
  list(
    panel = "B",
    title = "Myeloid relative enrichment by tissue group",
    workflow = "workflows/single_cell/01_process_scrna.R",
    operation = "select",
    input = "Fig03_B.tsv",
    required = c("sample_group", "cell_state", "roe"),
    output = "panel_B_data.tsv"
  ),
  list(
    panel = "C",
    title = "Monocyte-macrophage pseudotime",
    workflow = "workflows/single_cell/03_trajectory_analysis.R",
    operation = "select",
    input = "Fig03_C.tsv",
    required = c("pseudotime", "cell_state", "density"),
    output = "panel_C_data.tsv"
  ),
  list(
    panel = "D",
    title = "CCR2 monocyte and SPP1 TAM spatial maps",
    workflow = "workflows/spatial/cell2location/",
    operation = "select",
    input = "Fig03_D.tsv",
    required = c("sample", "x", "y", "cell_state", "q05_abundance"),
    output = "panel_D_data.tsv"
  ),
  list(
    panel = "E",
    title = "Spatial TAM M2 signature",
    workflow = "workflows/spatial/01_visium_preprocessing.R",
    operation = "select",
    input = "Fig03_E.tsv",
    required = c("sample", "x", "y", "m2_score"),
    output = "panel_E_data.tsv"
  ),
  list(
    panel = "F",
    title = "Neutrophil UMAP",
    workflow = "workflows/single_cell/01_process_scrna.R",
    operation = "select",
    input = "Fig03_F.tsv",
    required = c("UMAP_1", "UMAP_2", "cell_state"),
    output = "panel_F_data.tsv"
  ),
  list(
    panel = "G",
    title = "VEGFA TAN and Cancer_c3 spatial maps",
    workflow = "workflows/spatial/cell2location/",
    operation = "select",
    input = "Fig03_G.tsv",
    required = c("sample", "x", "y", "cell_state", "q05_abundance"),
    output = "panel_G_data.tsv"
  ),
  list(
    panel = "H",
    title = "Myeloid-state survival curves",
    workflow = "workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R",
    operation = "select",
    input = "Fig03_H.tsv",
    required = c("time", "survival", "signature"),
    output = "panel_H_data.tsv"
  ),
  list(
    panel = "I",
    title = "Neu_c2_VEGFA Hallmark enrichment",
    workflow = "workflows/single_cell/06_functional_enrichment.R",
    operation = "select",
    input = "Fig03_I.tsv",
    required = c("pathway", "NES", "FDR"),
    output = "panel_I_data.tsv"
  )
)

audit <- run_figure_analysis("Fig03", panel_plan, opts)
write_run_metadata(
  opts$output_dir,
  "Fig03_analysis",
  opts,
  list(
    computational_panels = sum(audit$status == "written"),
    documented_noncomputational_panels =
      sum(audit$status == "documented_noncomputational_panel")
  )
)
