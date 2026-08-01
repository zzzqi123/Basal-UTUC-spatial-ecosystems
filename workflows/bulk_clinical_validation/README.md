# Bulk transcriptomic and clinical validation

- `cibersortx/`: prepares the annotated single-cell reference and Japan-UTUC
  bulk mixture, documents the registered web-service hand-off and validates
  the returned relative cell-state fractions.
- `00_prepare_bulk_scores.R`: ESTIMATE Immune/Stromal scores and BASE47
  Basal/Luminal GSVA scores.
- `01_subtype_clinical_analysis.R`: pROC subtype classification, maximally
  selected cut points, DSS log-rank tests, Cox models and five-year timeROC.
- `02_japan_utuc_validation.R`: Japan-UTUC patient-level cellular-program
  scores, logistic models for muscle invasion and Cox models for
  disease-specific survival.
- `03_external_blca_validation.R`: external BLCA subtype, stage-interaction
  linear models and dataset-stratified survival checks.

The Japan-UTUC inputs are CIBERSORTx-estimated cell-state proportions from bulk
RNA-seq, produced through `cibersortx/01_prepare_inputs.R` and imported through
`cibersortx/02_import_fractions.R`. Rank-based inverse normal transforms are
applied to each component, the two components are averaged with equal weight,
and the score is standardized. These scores represent joint cellular-program
abundance; they do not measure spatial adjacency and are never produced by the
spatial workflow.
