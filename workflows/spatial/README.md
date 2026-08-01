# Spatial transcriptomic workflows

## Single-cell-reference to spatial deconvolution

- `cell2location/`: the discovery UTUC Visium workflow, including reference
  signatures, spatial mapping, posterior export and q05 abundance niches.
- `06_rctd_deconvolution.R`: the external BLCA spatial workflow. GSE299573
  Visium HD uses `doublet` mode; GSE319536 Visium uses `full` mode.

These workflows estimate cell-state abundance at spatial locations. They are
separate from bulk CIBERSORTx deconvolution and from downstream spatial
co-localization scores.

## Discovery UTUC Visium

- `01_visium_preprocessing.R`: reads Space Ranger outputs, retains raw counts
  for count models and keeps transformed values for visualization.
- `07_cellstate_correlation_colocalization.R`: within-section Spearman
  correlations, the manuscript three-level ordinal co-localization product and
  a separately named continuous joint-abundance score.
- `08_spagene_lr_colocalization.R`: SpaGene ligand-receptor analysis and the
  local kNN cross-neighbor score used for spatial maps.
- `09_spacet_gene_set_scores.R`: SpaCET quality control and Hallmark,
  CancerCellState, TLS and custom spatial gene-set scores.
- `15_cellchat_spatial.R`: spatial-mode CellChat with the
  local coordinate, distance and contact parameters; run once per section.

## Multiscale ecosystems and boundaries

- `02_multiscale_pair_burden.py`: q05 density-scaled pair burden over exact
  Visium rings 0-2 and 500 within-section positional permutations.
- `03_prepare_boundary_input.py`: posterior-mean malignant fraction and a
  section-specific tumor threshold.
- `04_infer_boundary_stgrads.R`: stGrads 2.0 boundary and signed distance.
- `05_boundary_profiles.R`: section-specific GAM profiles from -6 to +6 spot
  spacings.
- `13_effector_boundary_profiles.R`: top-15% Niche1 boundary anchors with
  exact ring-1 neighbors on the outer non-tumor and adjacent tumor sides;
  immune-effector programs are standardized within section and summarized as
  the three-compartment Fig. 6G profile.
- `14_niche_functional_analysis.R`: one integrated ranked gene list per niche
  for Hallmark GSEA, plus MI-section models containing both niche burdens and
  adjustments for library size, total inferred abundance and malignant-cell
  fraction. Spatial-block robust section estimates are combined by
  fixed-effect meta-analysis for Supplementary Fig. S14.

Conservative maps and pair burden use q05 abundance. Posterior means are used
only for the declared continuous boundary profile.

## External validation

- `10_visiumhd_niche_colocalization.R`: same-bin and kNN SPP1-TAM/FAP-myCAF
  co-enrichment from GSE299573 RCTD proportions.
- `11a_prepare_external_visium_scores.R`: 22-section GSE319536 contract,
  UCell Basal/luminal scores, epithelial anchor and exact rings 0-2.
- `11_external_visium_basal_axis.R`: per-section GAM curves, paired
  upper-versus-lower effects and equal-section bootstrap intervals.
- `12_geomx_roi_validation.R`: GSE296955 ROI-level composite programs,
  Spearman tests and BH correction.

Example RCTD configs are `../../config/rctd_gse299573.example.yaml` and
`../../config/rctd_gse319536.example.yaml`. Run `06_rctd_deconvolution.R` once per
section, then concatenate the de-identified proportion tables with a `section`
column before the GSE319536 preparation step.

Japan-UTUC is a bulk clinical cohort and remains under
`../bulk_clinical_validation/`; it does not provide spatial co-localization.
