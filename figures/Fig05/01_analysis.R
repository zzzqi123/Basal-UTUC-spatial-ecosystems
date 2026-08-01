#!/usr/bin/env Rscript

# Fig05: Global cell-cell communication and spatial mapping of SPP1+ TAM-FAP+ myCAF signaling in Basal UTUC
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
    title = "Number of inferred interactions",
    workflow = "workflows/single_cell/11_cellchat.R",
    operation = "select",
    input = "Fig05_A.tsv",
    required = c("source", "target", "count"),
    output = "panel_A_data.tsv"
  ),
  list(
    panel = "B",
    title = "Aggregated interaction strength",
    workflow = "workflows/single_cell/11_cellchat.R",
    operation = "select",
    input = "Fig05_B.tsv",
    required = c("source", "target", "weight"),
    output = "panel_B_data.tsv"
  ),
  list(
    panel = "C",
    title = "Outgoing and incoming communication centrality",
    workflow = "workflows/single_cell/11_cellchat.R",
    operation = "select",
    input = "Fig05_C.tsv",
    required = c("cell_state", "outgoing", "incoming"),
    output = "panel_C_data.tsv"
  ),
  list(
    panel = "D",
    title = "Selected SPP1 TAM-myCAF ligand-receptor probabilities",
    workflow = "workflows/single_cell/11_cellchat.R",
    operation = "select",
    input = "Fig05_D.tsv",
    required = c("source", "target", "ligand", "receptor", "probability", "p_value"),
    output = "panel_D_data.tsv"
  ),
  list(
    panel = "E",
    title = "TGFB1-(TGFBR1+TGFBR2) spatial signal",
    workflow = "workflows/spatial/08_spagene_lr_colocalization.R",
    operation = "select",
    input = "Fig05_E.tsv",
    required = c("sample", "x", "y", "interaction_score"),
    output = "panel_E_data.tsv"
  ),
  list(
    panel = "F",
    title = "SPP1-(ITGA8+ITGB1) spatial signal",
    workflow = "workflows/spatial/08_spagene_lr_colocalization.R",
    operation = "select",
    input = "Fig05_F.tsv",
    required = c("sample", "x", "y", "interaction_score"),
    output = "panel_F_data.tsv"
  ),
  list(
    panel = "G",
    title = "NMI-Basal SPP1 and TGF-beta spatial communication",
    workflow = "workflows/spatial/15_cellchat_spatial.R",
    operation = "select",
    input = "Fig05_G.tsv",
    required = c("stage", "pathway", "source", "target", "probability", "p_value"),
    output = "panel_G_data.tsv"
  ),
  list(
    panel = "H",
    title = "MI-Basal SPP1 and TGF-beta spatial communication",
    workflow = "workflows/spatial/15_cellchat_spatial.R",
    operation = "select",
    input = "Fig05_H.tsv",
    required = c("stage", "pathway", "source", "target", "probability", "p_value"),
    output = "panel_H_data.tsv"
  )
)

audit <- run_figure_analysis("Fig05", panel_plan, opts)
write_run_metadata(
  opts$output_dir,
  "Fig05_analysis",
  opts,
  list(
    computational_panels = sum(audit$status == "written"),
    documented_noncomputational_panels =
      sum(audit$status == "documented_noncomputational_panel")
  )
)
