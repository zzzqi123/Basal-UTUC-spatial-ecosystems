# Bulk transcriptomic and clinical validation

- `01_subtype_clinical_analysis.R`: subtype, stage, marker ROC and survival
  summaries used in Figures 1 and 11.
- `02_japan_utuc_validation.R`: Japan-UTUC patient-level cellular-program
  scores, logistic models for muscle invasion and Cox models for
  disease-specific survival.
- `03_external_blca_validation.R`: external BLCA subtype and survival checks.

The Japan-UTUC inputs are CIBERSORTx-estimated cell-state proportions from bulk
RNA-seq. Rank-based inverse normal transforms are applied to each component,
the two components are averaged with equal weight, and the score is
standardized. These scores represent joint cellular-program abundance; they do
not measure spatial adjacency and are never produced by the spatial workflow.
