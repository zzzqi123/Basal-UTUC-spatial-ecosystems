#!/usr/bin/env Rscript

# Fig06: Spatial organization and receiver programs of the SPP1+ TAM-FAP+ myCAF niche in Basal UTUC
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
    workflow = "workflows/spatial/07_cellstate_correlation_colocalization.R",
    operation = "select",
    input = "Fig06_A.tsv",
    required = c("sample", "x", "y", "pair_id", "colocalization_score"),
    output = "panel_A_data.tsv"
  ),
  list(
    panel = "B",
    title = "MI-Basal spatial co-localization",
    workflow = "workflows/spatial/07_cellstate_correlation_colocalization.R",
    operation = "select",
    input = "Fig06_B.tsv",
    required = c("sample", "x", "y", "pair_id", "colocalization_score"),
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
    title = "NicheNet macrophage-derived ligand activity",
    workflow = "workflows/communication/02_nichenet_tam_to_mycaf.R",
    operation = "select",
    input = "Fig06_D.tsv",
    required = c("ligand", "aupr_corrected", "receiver_group"),
    output = "panel_D_data.tsv"
  ),
  list(
    panel = "E",
    title = "NicheNet ligand-receptor prior interaction potential",
    workflow = "workflows/communication/02_nichenet_tam_to_mycaf.R",
    operation = "select",
    input = "Fig06_E.tsv",
    required = c("ligand", "receptor", "prior_interaction_potential"),
    output = "panel_E_data.tsv"
  ),
  list(
    panel = "F",
    title = "MI-associated FAP myCAF ligand-target potential",
    workflow = "workflows/communication/02_nichenet_tam_to_mycaf.R",
    operation = "select",
    input = "Fig06_F.tsv",
    required = c("ligand", "target", "regulatory_potential"),
    output = "panel_F_data.tsv"
  ),
  list(
    panel = "G",
    title = "Effector-immune programs across Niche1-high boundaries",
    workflow = "workflows/spatial/13_effector_boundary_profiles.R",
    operation = "select",
    input = "Fig06_G.tsv",
    required = c("sample", "program", "boundary_position", "mean_score"),
    output = "panel_G_data.tsv"
  ),
  list(
    panel = "H",
    title = "FAP myCAF receiver-gene overlap across comparisons",
    workflow = "workflows/communication/02_nichenet_tam_to_mycaf.R",
    operation = "select",
    input = "Fig06_H.tsv",
    required = c("gene_set", "membership", "count"),
    output = "panel_H_data.tsv"
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
