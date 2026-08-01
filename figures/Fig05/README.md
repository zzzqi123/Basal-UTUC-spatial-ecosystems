# Fig05: Global cell-cell communication and spatial mapping of SPP1+ TAM-FAP+ myCAF signaling in Basal UTUC

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | Number of inferred interactions | `workflows/communication/01_cellchat.R` |
| B | Aggregated interaction strength | `workflows/communication/01_cellchat.R` |
| C | Outgoing and incoming communication centrality | `workflows/communication/01_cellchat.R` |
| D | Selected SPP1 TAM-myCAF ligand-receptor probabilities | `workflows/communication/01_cellchat.R` |
| E | TGFB1-(TGFBR1+TGFBR2) spatial signal | `workflows/spatial/08_spagene_lr_colocalization.R` |
| F | SPP1-(ITGA8+ITGB1) spatial signal | `workflows/spatial/08_spagene_lr_colocalization.R` |
| G | NMI-Basal SPP1 and TGF-beta spatial communication | `workflows/communication/03_cellchat_spatial.R` |
| H | MI-Basal SPP1 and TGF-beta spatial communication | `workflows/communication/03_cellchat_spatial.R` |

`01_analysis.R` declares each panel's input table and required columns. It
performs lightweight panel assembly only; model fitting remains in
`workflows/`. `02_plot.R` renders standard vector panels and records
package-native or non-computational panels without fabricating a replacement.

## Run

```bash
Rscript figures/Fig05/01_analysis.R \
  --config figures/Fig05/config.yaml \
  --input-dir data/processed/Fig05 \
  --output-dir outputs/Fig05 \
  --seed 20260730 --threads 4

Rscript figures/Fig05/02_plot.R \
  --config figures/Fig05/config.yaml \
  --input-dir outputs/Fig05 \
  --output-dir outputs/Fig05 \
  --seed 20260730 --threads 4
```

Private patient tables and large objects are not distributed. The expected
de-identified table schemas are visible directly in `01_analysis.R`.
