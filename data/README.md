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
- `utuc_annotated_scrna.rds`: curator-reviewed full Seurat object handed from
  marker review to downstream lineage, communication and pathway workflows;
- `hallmark_gene_sets.tsv`: columns `pathway` and `gene`;
- `hg38_gene_order.tsv`: inferCNV gene order;
- `spatial_cellstate_abundance.tsv.gz`: one row per section and spot with q05
  cell-state abundance columns;
- `prespecified_cellstate_pairs.tsv`: `pair_id`, `state_1`, `state_2`;
- `ligand_receptor_pairs.tsv`: `pair_id`, `ligand`, `receptor`;
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
