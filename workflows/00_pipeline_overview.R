#!/usr/bin/env Rscript

# Article-level execution map. Each row is a substantive hand-off. Private
# cohorts and large objects are inputs, not repository contents.

scripts <- c(
  "workflows/single_cell/01_process_scrna.R",
  "workflows/single_cell/01b_annotation_and_markers.R",
  "workflows/single_cell/01c_lineage_subclustering.R",
  "workflows/single_cell/02a_infercnv_adjacent_epithelial_reference.R",
  "workflows/single_cell/02_infercnv_non_epi_reference.R",
  "workflows/single_cell/02b_infercnv_reference_robustness.R",
  "workflows/single_cell/03_trajectory_analysis.R",
  "workflows/single_cell/03b_monocle3_robustness.R",
  "workflows/single_cell/04_cytotrace2.R",
  "workflows/single_cell/05_pyscenic.sh",
  "workflows/single_cell/06_functional_enrichment.R",
  "workflows/single_cell/07_pathway_activity.R",
  "workflows/single_cell/08_marker_visualization.R",
  "workflows/single_cell/09_roe_composition.R",
  "workflows/genetics/01_scpagwas.R",
  "workflows/genetics/03_phewas_mr_spp1.R",
  "workflows/spatial/cell2location/01_reference_signatures.py",
  "workflows/spatial/cell2location/02_spatial_mapping.py",
  "workflows/spatial/cell2location/03_export_abundance.py",
  "workflows/spatial/cell2location/04_spatial_niches.py",
  "workflows/spatial/07_cellstate_correlation_colocalization.R",
  "workflows/spatial/08_spagene_lr_colocalization.R",
  "workflows/spatial/09_spacet_gene_set_scores.R",
  "workflows/communication/01_cellchat.R",
  "workflows/communication/03_cellchat_spatial.R",
  "workflows/communication/02_nichenet_tam_to_mycaf.R",
  "workflows/perturbation/01_spp1_virtual_knockout.R",
  "workflows/perturbation/02_sctenifoldknk_tme_targets.R",
  "workflows/spatial/02_multiscale_pair_burden.py",
  "workflows/spatial/03_prepare_boundary_input.py",
  "workflows/spatial/04_infer_boundary_stgrads.R",
  "workflows/spatial/05_boundary_profiles.R",
  "workflows/spatial/13_effector_boundary_profiles.R",
  "workflows/spatial/14_niche_functional_analysis.R",
  "workflows/spatial/06_external_rctd.R",
  "workflows/spatial/10_visiumhd_niche_colocalization.R",
  "workflows/spatial/11a_prepare_external_visium_scores.R",
  "workflows/spatial/11_external_visium_basal_axis.R",
  "workflows/spatial/12_geomx_roi_validation.R",
  "workflows/bulk_clinical_validation/00_prepare_bulk_scores.R",
  "workflows/bulk_clinical_validation/02_japan_utuc_validation.R",
  "figures/FigXX/01_analysis.R"
)

branches <- vapply(scripts, function(script) {
  if (startsWith(script, "workflows/single_cell/")) return("single_cell")
  if (startsWith(script, "workflows/genetics/")) return("genetics")
  if (startsWith(script, "workflows/spatial/")) return("spatial")
  if (startsWith(script, "workflows/communication/")) return("communication")
  if (startsWith(script, "workflows/perturbation/")) return("perturbation")
  if (startsWith(script, "workflows/bulk_clinical_validation/")) {
    return("bulk_clinical")
  }
  "figure_assembly"
}, character(1))

pipeline <- data.frame(
  order = seq_along(scripts),
  branch = branches,
  script = scripts,
  stringsAsFactors = FALSE
)

stopifnot(nrow(pipeline) == length(scripts))

if (sys.nframe() == 0L) {
  write.table(
    pipeline,
    file = stdout(),
    sep = "\t",
    quote = FALSE,
    row.names = FALSE
  )
}
