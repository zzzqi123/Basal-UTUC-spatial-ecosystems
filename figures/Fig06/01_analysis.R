#!/usr/bin/env Rscript

# Fig06: SPP1 TAM-myCAF spatial coupling and candidate signaling
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
    title = "NMI-Basal spatial co-localization",
    workflow = "workflows/spatial/cell2location/",
    operation = "select",
    input = "Fig06_A.tsv",
    required = c("sample", "x", "y", "component", "q05_abundance"),
    output = "panel_A_data.tsv"
  ),
  list(
    panel = "B",
    title = "MI-Basal spatial co-localization",
    workflow = "workflows/spatial/cell2location/",
    operation = "select",
    input = "Fig06_B.tsv",
    required = c("sample", "x", "y", "component", "q05_abundance"),
    output = "panel_B_data.tsv"
  ),
  list(
    panel = "C",
    title = "Multiplex immunofluorescence",
    workflow = "non-computational source panel; code not applicable",
    operation = "document_only"
  ),
  list(
    panel = "D",
    title = "NicheNet multi-ligand candidate network",
    workflow = "workflows/communication/02_nichenet_tam_to_mycaf.R",
    operation = "select",
    input = "Fig06_D.tsv",
    required = c("ligand", "aupr_corrected", "receiver_target"),
    output = "panel_D_data.tsv"
  ),
  list(
    panel = "E",
    title = "TGF-beta ligand-receptor spatial signal",
    workflow = "workflows/spatial/01_visium_preprocessing.R",
    operation = "select",
    input = "Fig06_E.tsv",
    required = c("sample", "x", "y", "interaction_score"),
    output = "panel_E_data.tsv"
  ),
  list(
    panel = "F",
    title = "SPP1-integrin spatial signal",
    workflow = "workflows/spatial/01_visium_preprocessing.R",
    operation = "select",
    input = "Fig06_F.tsv",
    required = c("sample", "x", "y", "interaction_score"),
    output = "panel_F_data.tsv"
  )
)

audit <- run_figure_analysis("Fig06", panel_plan, opts)
write_run_metadata(
  opts$output_dir,
  "Fig06_analysis",
  opts,
  list(
    computational_panels = sum(audit$status == "written"),
    documented_noncomputational_panels =
      sum(audit$status == "documented_noncomputational_panel")
  )
)
