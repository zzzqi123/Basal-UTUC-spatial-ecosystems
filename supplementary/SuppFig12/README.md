# SuppFig12: Single-cell validation of bladder urothelial carcinoma cell-type annotations and SPP1/FAP/CXCR4-associated compartments

This module uses the two public bladder cancer scRNA-seq resources listed in
Supplementary Table 5: GSE222315 (nine tumors and four adjacent normal
samples) and the seven retained tumor specimens from GSE267718.

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | Major-lineage UMAP | `workflows/single_cell/01_process_scrna.R` |
| B | Canonical lineage-marker dot plot | `workflows/single_cell/01b_annotation_and_markers.R -> workflows/single_cell/08_marker_visualization.R` |
| C | Neutrophil-marker audit | `workflows/single_cell/01b_annotation_and_markers.R -> workflows/single_cell/08_marker_visualization.R` |
| D | Myeloid reclustering and SPP1 density | `workflows/single_cell/01c_lineage_subclustering.R -> workflows/single_cell/01b_annotation_and_markers.R -> workflows/single_cell/08_marker_visualization.R` |
| E | Fibroblast reclustering and FAP density | `workflows/single_cell/01c_lineage_subclustering.R -> workflows/single_cell/01b_annotation_and_markers.R -> workflows/single_cell/08_marker_visualization.R` |
| F | Endothelial reclustering and CXCR4 density | `workflows/single_cell/01c_lineage_subclustering.R -> workflows/single_cell/01b_annotation_and_markers.R -> workflows/single_cell/08_marker_visualization.R` |

`01_analysis.R` records each panel's source workflow, input table and required
columns. `02_plot.R` draws the standard vector panels; panels exported directly
from an analysis package or generated experimentally are listed in the panel
map.

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

Required input columns are listed directly in `01_analysis.R`; expected files
are listed in `expected_outputs.txt`. The upstream processing inputs are
`gse222315_scrna.h5ad` and `gse267718_tumor_scrna.h5ad`; the two cohorts retain
their dataset labels during Seurat processing and are combined only for the
figure-level exports listed here.
