# SuppFig04: Spatial transcriptomic analysis of Basal UTUC across pathological stages

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | H&E images of profiled sections | `non-computational source panel; code not applicable` |
| B | q05 abundance Leiden niches | `workflows/spatial/cell2location/` |
| C | cell2location cell-state maps | `workflows/spatial/cell2location/` |
| D | Spatial Basal signature | `workflows/spatial/01_visium_preprocessing.R` |

`01_analysis.R` records each panel's source workflow, input table and required
columns. `02_plot.R` draws the standard vector panels; panels exported directly
from an analysis package or generated experimentally are listed in the panel
map.

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

Required input columns are listed directly in `01_analysis.R`; expected files
are listed in `expected_outputs.txt`.
