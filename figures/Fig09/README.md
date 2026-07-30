# Fig09: VEGFA TAN-CXCR4 tip EC angiogenic program

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | NMI-Basal component co-localization | `workflows/spatial/07_cellstate_correlation_colocalization.R` |
| B | MI-Basal component co-localization | `workflows/spatial/07_cellstate_correlation_colocalization.R` |
| C | Multiplex immunofluorescence | `non-computational source panel; code not applicable` |
| D | Selected CellChat interactions | `workflows/communication/01_cellchat.R` |
| E | VEGFA-VEGFR1 spatial signal | `workflows/spatial/08_spagene_lr_colocalization.R` |
| F | NAMPT-INSR spatial signal | `workflows/spatial/08_spagene_lr_colocalization.R` |

`01_analysis.R` declares each panel's input table and required columns. It
performs lightweight panel assembly only; model fitting remains in
`workflows/`. `02_plot.R` renders standard vector panels and records
package-native or non-computational panels without fabricating a replacement.

## Run

```bash
Rscript figures/Fig09/01_analysis.R \
  --config figures/Fig09/config.yaml \
  --input-dir data/processed/Fig09 \
  --output-dir outputs/Fig09 \
  --seed 20260730 --threads 4

Rscript figures/Fig09/02_plot.R \
  --config figures/Fig09/config.yaml \
  --input-dir outputs/Fig09 \
  --output-dir outputs/Fig09 \
  --seed 20260730 --threads 4
```

Private patient tables and large objects are not distributed. The expected
de-identified table schemas are visible directly in `01_analysis.R`.
