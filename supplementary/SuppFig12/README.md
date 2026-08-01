# SuppFig12: Single-cell validation of bladder urothelial carcinoma cell-type annotations and SPP1/FAP/CXCR4-associated compartments

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | Major-lineage UMAP | `workflows/single_cell/01_process_scrna.R` |
| B | Canonical lineage-marker dot plot | `workflows/single_cell/01b_annotation_and_markers.R -> workflows/single_cell/08_marker_visualization.R` |
| C | Neutrophil-marker audit | `workflows/single_cell/01b_annotation_and_markers.R -> workflows/single_cell/08_marker_visualization.R` |
| D | Myeloid reclustering and SPP1 density | `workflows/single_cell/01c_lineage_subclustering.R -> workflows/single_cell/01b_annotation_and_markers.R -> workflows/single_cell/08_marker_visualization.R` |
| E | Fibroblast reclustering and FAP density | `workflows/single_cell/01c_lineage_subclustering.R -> workflows/single_cell/01b_annotation_and_markers.R -> workflows/single_cell/08_marker_visualization.R` |
| F | Endothelial reclustering and CXCR4 density | `workflows/single_cell/01c_lineage_subclustering.R -> workflows/single_cell/01b_annotation_and_markers.R -> workflows/single_cell/08_marker_visualization.R` |

`01_analysis.R` declares each panel's input table and required columns. It
performs lightweight panel assembly only; model fitting remains in
`workflows/`. `02_plot.R` renders standard vector panels and records
package-native or non-computational panels without fabricating a replacement.

## Run

```bash
Rscript supplementary/SuppFig12/01_analysis.R \
  --config supplementary/SuppFig12/config.yaml \
  --input-dir data/processed/SuppFig12 \
  --output-dir outputs/SuppFig12 \
  --seed 20260730 --threads 4

Rscript supplementary/SuppFig12/02_plot.R \
  --config supplementary/SuppFig12/config.yaml \
  --input-dir outputs/SuppFig12 \
  --output-dir outputs/SuppFig12 \
  --seed 20260730 --threads 4
```

Private patient tables and large objects are not distributed. The expected
de-identified table schemas are visible directly in `01_analysis.R`.
