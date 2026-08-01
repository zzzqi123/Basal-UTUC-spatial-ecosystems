# Fig11: Clinical stratification and subtype-discrimination performance of SPP1 and FAP in UTUC

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | DSS in Basal NMI versus Basal MI | `workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R` |
| B | SPP1 and FAP correlations with Basal score | `workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R` |
| C | Subtype-classification ROC curves | `workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R` |
| D | Joint SPP1-FAP survival stratification | `workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R` |
| E | Time-dependent DSS AUC | `workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R` |

`01_analysis.R` records each panel's source workflow, input table and required
columns. `02_plot.R` draws the standard vector panels; panels exported directly
from an analysis package or generated experimentally are listed in the panel
map.

## Run

```bash
Rscript figures/Fig11/01_analysis.R \
  --config figures/Fig11/config.yaml \
  --input-dir data/processed/Fig11 \
  --output-dir outputs/Fig11 \
  --seed 20260730 --threads 4

Rscript figures/Fig11/02_plot.R \
  --config figures/Fig11/config.yaml \
  --input-dir outputs/Fig11 \
  --output-dir outputs/Fig11 \
  --seed 20260730 --threads 4
```

Required input columns are listed directly in `01_analysis.R`; expected files
are listed in `expected_outputs.txt`.
