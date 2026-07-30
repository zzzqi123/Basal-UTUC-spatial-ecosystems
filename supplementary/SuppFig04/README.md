# SuppFig04: Basal UTUC spatial analysis

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | H&E images of profiled sections | `non-computational source panel; code not applicable` |
| B | q05 abundance Leiden niches | `workflows/spatial/cell2location/` |
| C | cell2location cell-state maps | `workflows/spatial/cell2location/` |
| D | Spatial Basal signature | `workflows/spatial/01_visium_preprocessing.R` |

`01_analysis.R` declares each panel's input table and required columns. It
performs lightweight panel assembly only; model fitting remains in
`workflows/`. `02_plot.R` renders standard vector panels and records
package-native or non-computational panels without fabricating a replacement.

## Run

```bash
Rscript supplementary/SuppFig04/01_analysis.R \
  --config supplementary/SuppFig04/config.yaml \
  --input-dir data/processed/SuppFig04 \
  --output-dir outputs/SuppFig04 \
  --seed 20260730 --threads 4

Rscript supplementary/SuppFig04/02_plot.R \
  --config supplementary/SuppFig04/config.yaml \
  --input-dir outputs/SuppFig04 \
  --output-dir outputs/SuppFig04 \
  --seed 20260730 --threads 4
```

Private patient tables and large objects are not distributed. The expected
de-identified table schemas are visible directly in `01_analysis.R`.
