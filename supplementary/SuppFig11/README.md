# SuppFig11: Bulk transcriptomic validation of the SPP1-associated Basal immune-stromal program in bladder urothelial carcinoma

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | Immune and stromal scores | `workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/03_external_blca_validation.R` |
| B | FAP and SPP1 expression | `workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/03_external_blca_validation.R` |
| C | SPP1 correlations | `workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/03_external_blca_validation.R` |
| D | Subtype-classification ROC | `workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/03_external_blca_validation.R` |
| E | External survival validation | `workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/03_external_blca_validation.R` |

`01_analysis.R` declares each panel's input table and required columns. It
performs lightweight panel assembly only; model fitting remains in
`workflows/`. `02_plot.R` renders standard vector panels and records
package-native or non-computational panels without fabricating a replacement.

## Run

```bash
Rscript supplementary/SuppFig11/01_analysis.R \
  --config supplementary/SuppFig11/config.yaml \
  --input-dir data/processed/SuppFig11 \
  --output-dir outputs/SuppFig11 \
  --seed 20260730 --threads 4

Rscript supplementary/SuppFig11/02_plot.R \
  --config supplementary/SuppFig11/config.yaml \
  --input-dir outputs/SuppFig11 \
  --output-dir outputs/SuppFig11 \
  --seed 20260730 --threads 4
```

Private patient tables and large objects are not distributed. The expected
de-identified table schemas are visible directly in `01_analysis.R`.
