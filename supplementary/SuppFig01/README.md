# SuppFig01: Molecular subtype and TME features

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | Subtype distribution across stages | `workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R` |
| B | Tumor purity within stage | `workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R` |
| C | Immune, myeloid and stromal marker expression | `workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R` |
| D | Major-cell-type Sankey summary | `workflows/single_cell/01_process_scrna.R` |

`01_analysis.R` declares each panel's input table and required columns. It
performs lightweight panel assembly only; model fitting remains in
`workflows/`. `02_plot.R` renders standard vector panels and records
package-native or non-computational panels without fabricating a replacement.

## Run

```bash
Rscript supplementary/SuppFig01/01_analysis.R \
  --config supplementary/SuppFig01/config.yaml \
  --input-dir data/processed/SuppFig01 \
  --output-dir outputs/SuppFig01 \
  --seed 20260730 --threads 4

Rscript supplementary/SuppFig01/02_plot.R \
  --config supplementary/SuppFig01/config.yaml \
  --input-dir outputs/SuppFig01 \
  --output-dir outputs/SuppFig01 \
  --seed 20260730 --threads 4
```

Private patient tables and large objects are not distributed. The expected
de-identified table schemas are visible directly in `01_analysis.R`.
