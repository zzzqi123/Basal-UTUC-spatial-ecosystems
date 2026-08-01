# Data access

No patient-level or large binary data are stored in this repository.

Create the following local directories after obtaining the relevant approvals
and public datasets:

```text
data/
├── private/       institutional and controlled-access inputs
├── public/        downloaded public datasets
└── processed/     local analysis-ready objects
```

Expected file names and accessions are defined in
[`../manifests/data_manifest.tsv`](../manifests/data_manifest.tsv).

The code validates schemas and sample identifiers but does not attempt to
download controlled-access data. Never commit the three directories above.

Method-specific input contracts include:

- `bulk_expression_symbols.tsv.gz`, `bulk_sample_metadata.tsv` and
  `base47_gene_sets.tsv`: gene-symbol expression, sample metadata and
  `program/gene` BASE47 definitions for ESTIMATE/GSVA;
- `utuc_bulk_expression_clinical.tsv`: de-identified DSS endpoint, subtype,
  stage and prespecified marker expression for survival and ROC workflows;
- `japan_utuc_bulk_expression.tsv.gz`: gene-symbol-by-sample expression table
  used to write the 158-sample CIBERSORTx mixture matrix;
- `japan_utuc_clinical.tsv`: de-identified `sample_id`, muscle-invasion, DSS,
  age and sex table used only after CIBERSORTx fraction import;
- `CIBERSORTx_Job2_Results.csv`: registered-service relative-fraction output;
  it is validated and converted to `japan_utuc_program_scores.tsv` by the
  public import script;
- `utuc_annotated_scrna.rds`: curator-reviewed full Seurat object handed from
  marker review to downstream lineage, communication and pathway workflows;
- `utuc_malignant_epithelial.rds`: the same annotated Seurat object (or an
  analysis-ready subset) retaining the `RNA` raw-count layer and
  `second_celltype_byhand`; the public SPP1 workflow reselects only
  `Cancer_c0`-`Cancer_c4` cells before network construction;
- `hallmark_gene_sets.tsv`: columns `pathway` and `gene` for shared
  single-cell enrichment workflows;
- `hg38_gene_order.tsv`: inferCNV gene order;
- `infercnv_primary_matched_matrix.tsv.gz` and
  `infercnv_sensitivity_matched_matrix.tsv.gz`: gene-by-cell matrices exported
  on exactly matched epithelial cells and common genes for Supplementary
  Fig. S13, accompanied by `infercnv_cell_metadata.tsv`,
  `malignant_reference_assignments.tsv`, `malignant_marker_profiles.tsv` and
  `malignant_hallmark_nes.tsv`;
- `spatial_cellstate_abundance.tsv.gz`: one row per section and spot with q05
  cell-state abundance columns;
- `prespecified_cellstate_pairs.tsv`: `pair_id`, `state_1`, `state_2`;
- `ligand_receptor_pairs.tsv`: `pair_id`, `ligand`, `receptor`;
- `niche1_boundary_spots.tsv` and `visium_ring1_edges.tsv`: de-identified
  spot compartments, Niche1 burden, three immune-effector program scores and
  exact ring-1 adjacency for Fig. 6G;
- `niche_component_gene_effects.tsv`, `pathway_gene_sets.tsv` and
  `spatial_niche_pathway_scores.tsv`: component-resolved gene effects,
  `pathway/gene` definitions and MI-section spot-level covariates for
  Supplementary Fig. S14;
- `external_visium_sections.rds`: named list containing the 22 GSE319536
  sections;
- `external_visium_rctd_proportions.tsv.gz`: concatenated per-section
  full-mode RCTD proportions;
- `geomx_roi_signature_scores.tsv`: de-identified GSE296955 ROI metadata and
  prespecified program scores;
- `geomx_program_columns.tsv`: one `program` column listing only the
  prespecified GeoMx scores to test, preventing clinical or QC covariates from
  being analyzed as biological programs;
- `spp1_phewas_smr_results.tsv.gz`: one normalized SMR/HEIDI row per UK
  Biobank binary phenotype with identifiers, PheCode category, case count,
  beta, standard error, SMR p value and HEIDI p value.
