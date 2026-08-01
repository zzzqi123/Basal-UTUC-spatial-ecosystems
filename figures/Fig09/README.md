# Fig09: Spatial coupling and ligand-receptor interactions between CXCR4+ tip ECs and VEGFA+ TAN in Basal UTUC

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | Selected VEGFA TAN-tip EC ligand-receptor probabilities | `workflows/single_cell/11_cellchat.R` |
| B | VEGFA-VEGFR1 spatial signal | `workflows/spatial/08_spagene_lr_colocalization.R` |
| C | NAMPT-INSR spatial signal | `workflows/spatial/08_spagene_lr_colocalization.R` |
| D | NMI-Basal VEGFA TAN-tip EC co-localization | `workflows/spatial/07_cellstate_correlation_colocalization.R` |
| E | MI-Basal VEGFA TAN-tip EC co-localization | `workflows/spatial/07_cellstate_correlation_colocalization.R` |
| F | Multiplex immunofluorescence | `non-computational source panel; code not applicable` |

`01_analysis.R` records each panel's source workflow, input table and required
columns. `02_plot.R` draws the standard vector panels; panels exported directly
from an analysis package or generated experimentally are listed in the panel
map.

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

Required input columns are listed directly in `01_analysis.R`; expected files
are listed in `expected_outputs.txt`.
