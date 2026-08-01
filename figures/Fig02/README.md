# Fig02: Spatial transcriptomic analysis and validation of Basal UTUC tumors across pathological stages

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | cell2location major-cell-type maps | `workflows/spatial/cell2location/` |
| B | Within-section cell-state correlations | `workflows/spatial/07_cellstate_correlation_colocalization.R` |
| C | CK5/6, GATA3, FAP and SPP1 immunohistochemistry | `non-computational source panel; code not applicable` |

`01_analysis.R` records each panel's source workflow, input table and required
columns. `02_plot.R` draws the standard vector panels; panels exported directly
from an analysis package or generated experimentally are listed in the panel
map.

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

Required input columns are listed directly in `01_analysis.R`; expected files
are listed in `expected_outputs.txt`.
