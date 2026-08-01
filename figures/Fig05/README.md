# Fig05: Global cell-cell communication and spatial mapping of SPP1+ TAM-FAP+ myCAF signaling in Basal UTUC

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | Number of inferred interactions | `workflows/single_cell/11_cellchat.R` |
| B | Aggregated interaction strength | `workflows/single_cell/11_cellchat.R` |
| C | Outgoing and incoming communication centrality | `workflows/single_cell/11_cellchat.R` |
| D | Selected SPP1 TAM-myCAF ligand-receptor probabilities | `workflows/single_cell/11_cellchat.R` |
| E | TGFB1-(TGFBR1+TGFBR2) spatial signal | `workflows/spatial/08_spagene_lr_colocalization.R` |
| F | SPP1-(ITGA8+ITGB1) spatial signal | `workflows/spatial/08_spagene_lr_colocalization.R` |
| G | NMI-Basal SPP1 and TGF-beta spatial communication | `workflows/spatial/15_cellchat_spatial.R` |
| H | MI-Basal SPP1 and TGF-beta spatial communication | `workflows/spatial/15_cellchat_spatial.R` |

`01_analysis.R` records each panel's source workflow, input table and required
columns. `02_plot.R` draws the standard vector panels; panels exported directly
from an analysis package or generated experimentally are listed in the panel
map.

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

Required input columns are listed directly in `01_analysis.R`; expected files
are listed in `expected_outputs.txt`.
