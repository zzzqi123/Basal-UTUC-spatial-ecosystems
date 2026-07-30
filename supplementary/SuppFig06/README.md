# SuppFig06: Malignant trajectories, programs and clinical relevance

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | Top markers and GO terms | `workflows/single_cell/06_functional_enrichment.R` |
| B | PCA-based malignant trajectory | `workflows/single_cell/03_trajectory_analysis.R` |
| C | Monocle3 pseudotime embeddings | `workflows/single_cell/03_trajectory_analysis.R` |
| D | Representative regulon activities | `workflows/single_cell/05_pyscenic.sh` |
| E | Cancer_c3 Hallmark enrichment | `workflows/single_cell/06_functional_enrichment.R` |
| F | Cancer_c3-Basal score correlation | `workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R` |
| G | Cancer_c4 DSS | `workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R` |
| H | Cancer_c4 enrichment | `workflows/single_cell/06_functional_enrichment.R` |

`01_analysis.R` declares each panel's input table and required columns. It
performs lightweight panel assembly only; model fitting remains in
`workflows/`. `02_plot.R` renders standard vector panels and records
package-native or non-computational panels without fabricating a replacement.

## Run

```bash
Rscript supplementary/SuppFig06/01_analysis.R \
  --config supplementary/SuppFig06/config.yaml \
  --input-dir data/processed/SuppFig06 \
  --output-dir outputs/SuppFig06 \
  --seed 20260730 --threads 4

Rscript supplementary/SuppFig06/02_plot.R \
  --config supplementary/SuppFig06/config.yaml \
  --input-dir outputs/SuppFig06 \
  --output-dir outputs/SuppFig06 \
  --seed 20260730 --threads 4
```

Private patient tables and large objects are not distributed. The expected
de-identified table schemas are visible directly in `01_analysis.R`.
