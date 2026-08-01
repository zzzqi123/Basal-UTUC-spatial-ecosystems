# SuppFig13: Robustness of malignant epithelial subcluster assignments and functional programs under alternative inferCNV reference selection

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | Original adjacent-epithelial-reference inferCNV heatmap | `workflows/single_cell/02a_infercnv_adjacent_epithelial_reference.R` |
| B | Within-sample non-epithelial-reference inferCNV heatmap | `workflows/single_cell/02_infercnv_non_epi_reference.R` |
| C | Cell-level CNV burden percentile concordance | `workflows/single_cell/02b_infercnv_reference_robustness.R` |
| D | Patient-specific CNV burden rank correlations | `workflows/single_cell/02b_infercnv_reference_robustness.R` |
| E | Original and revised malignant-subcluster UMAPs | `workflows/single_cell/02b_infercnv_reference_robustness.R` |
| F | Overlap of malignant cells under both references | `workflows/single_cell/02b_infercnv_reference_robustness.R` |
| G | Malignant-subcluster marker-profile concordance | `workflows/single_cell/02b_infercnv_reference_robustness.R` |
| H | Cancer_c0 and Cancer_c3 Hallmark NES concordance | `workflows/single_cell/02b_infercnv_reference_robustness.R` |

`01_analysis.R` records each panel's source workflow, input table and required
columns. `02_plot.R` draws the standard vector panels; panels exported directly
from an analysis package or generated experimentally are listed in the panel
map.

## Run

```bash
Rscript supplementary/SuppFig13/01_analysis.R \
  --config supplementary/SuppFig13/config.yaml \
  --input-dir data/processed/SuppFig13 \
  --output-dir outputs/SuppFig13 \
  --seed 20260730 --threads 4

Rscript supplementary/SuppFig13/02_plot.R \
  --config supplementary/SuppFig13/config.yaml \
  --input-dir outputs/SuppFig13 \
  --output-dir outputs/SuppFig13 \
  --seed 20260730 --threads 4
```

Required input columns are listed directly in `01_analysis.R`; expected files
are listed in `expected_outputs.txt`.
