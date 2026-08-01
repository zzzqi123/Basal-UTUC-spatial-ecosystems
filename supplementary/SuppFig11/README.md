# SuppFig11: Bulk transcriptomic validation of the SPP1-associated Basal immune-stromal program in bladder urothelial carcinoma

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | Immune and stromal scores | `workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/03_external_blca_validation.R` |
| B | FAP and SPP1 expression | `workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/03_external_blca_validation.R` |
| C | SPP1 correlations | `workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/03_external_blca_validation.R` |
| D | Subtype-classification ROC | `workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/03_external_blca_validation.R` |
| E | External survival validation | `workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/03_external_blca_validation.R` |

`01_analysis.R` records each panel's source workflow, input table and required
columns. `02_plot.R` draws the standard vector panels; panels exported directly
from an analysis package or generated experimentally are listed in the panel
map.

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

Required input columns are listed directly in `01_analysis.R`; expected files
are listed in `expected_outputs.txt`.
