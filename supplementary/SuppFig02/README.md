# SuppFig02: Single-cell RNA sequencing quality control, marker validation, and cell-type composition

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | Single-cell quality-control metrics | `workflows/single_cell/01_process_scrna.R` |
| B | Lineage-marker density maps | `workflows/single_cell/01b_annotation_and_markers.R -> workflows/single_cell/08_marker_visualization.R` |
| C | Major-cell-type proportions | `workflows/single_cell/01_process_scrna.R` |

`01_analysis.R` declares each panel's input table and required columns. It
performs lightweight panel assembly only; model fitting remains in
`workflows/`. `02_plot.R` renders standard vector panels and records
package-native or non-computational panels without fabricating a replacement.

## Run

```bash
Rscript supplementary/SuppFig02/01_analysis.R \
  --config supplementary/SuppFig02/config.yaml \
  --input-dir data/processed/SuppFig02 \
  --output-dir outputs/SuppFig02 \
  --seed 20260730 --threads 4

Rscript supplementary/SuppFig02/02_plot.R \
  --config supplementary/SuppFig02/config.yaml \
  --input-dir outputs/SuppFig02 \
  --output-dir outputs/SuppFig02 \
  --seed 20260730 --threads 4
```

Private patient tables and large objects are not distributed. The expected
de-identified table schemas are visible directly in `01_analysis.R`.
