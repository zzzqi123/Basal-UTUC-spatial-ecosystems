# Fig08: Epithelial SPP1 expression and functional effects of SPP1 knockdown in a urothelial carcinoma model

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | SPP1 expression in adjacent and malignant epithelial cells | `workflows/single_cell/01b_annotation_and_markers.R -> workflows/single_cell/08_marker_visualization.R` |
| B | Malignant-epithelial virtual-knockout enrichment | `workflows/single_cell/10_spp1_virtual_knockout.R` |
| C | SPP1 siRNA qRT-PCR | `non-computational source panel; code not applicable` |
| D | SPP1 knockdown western blot | `non-computational source panel; code not applicable` |
| E | J82 cell-viability assay | `non-computational source panel; code not applicable` |
| F | Transwell migration and invasion | `non-computational source panel; code not applicable` |
| G | Conditioned-medium HUVEC tube-formation assay | `non-computational source panel; code not applicable` |

`01_analysis.R` records each panel's source workflow, input table and required
columns. `02_plot.R` draws the standard vector panels; panels exported directly
from an analysis package or generated experimentally are listed in the panel
map.

## Run

```bash
Rscript figures/Fig08/01_analysis.R \
  --config figures/Fig08/config.yaml \
  --input-dir data/processed/Fig08 \
  --output-dir outputs/Fig08 \
  --seed 20260730 --threads 4

Rscript figures/Fig08/02_plot.R \
  --config figures/Fig08/config.yaml \
  --input-dir outputs/Fig08 \
  --output-dir outputs/Fig08 \
  --seed 20260730 --threads 4
```

Required input columns are listed directly in `01_analysis.R`; expected files
are listed in `expected_outputs.txt`.
