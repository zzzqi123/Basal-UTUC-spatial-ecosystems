# Fig02: Spatial transcriptomic landscape of Basal UTUC

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | cell2location major-cell-type maps | `workflows/spatial/cell2location/` |
| B | Within-section cell-state correlations | `workflows/spatial/cell2location/` |
| C | CK5/6, GATA3, FAP and SPP1 immunohistochemistry | `non-computational source panel; code not applicable` |

`01_analysis.R` declares each panel's input table and required columns. It
performs lightweight panel assembly only; model fitting remains in
`workflows/`. `02_plot.R` renders standard vector panels and records
package-native or non-computational panels without fabricating a replacement.

## Run

```bash
Rscript figures/Fig02/01_analysis.R \
  --config figures/Fig02/config.yaml \
  --input-dir data/processed/Fig02 \
  --output-dir outputs/Fig02 \
  --seed 20260730 --threads 4

Rscript figures/Fig02/02_plot.R \
  --config figures/Fig02/config.yaml \
  --input-dir outputs/Fig02 \
  --output-dir outputs/Fig02 \
  --seed 20260730 --threads 4
```

Private patient tables and large objects are not distributed. The expected
de-identified table schemas are visible directly in `01_analysis.R`.
