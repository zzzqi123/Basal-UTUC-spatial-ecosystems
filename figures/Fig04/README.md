# Fig04: Functional states and spatial distribution of stromal and endothelial subclusters in UTUC

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | Mesenchymal UMAP | `workflows/single_cell/01c_lineage_subclustering.R` |
| B | Mesenchymal pseudotime branches | `workflows/single_cell/03_trajectory_analysis.R` |
| C | CAF functional-state radar summary | `workflows/single_cell/07_pathway_activity.R` |
| D | myCAF correlations with Basal and TGF-beta scores | `workflows/single_cell/07_pathway_activity.R` |
| E | Tip-cell correlations with myCAF and hypoxia | `workflows/single_cell/07_pathway_activity.R` |
| F | Stromal and endothelial spatial maps | `workflows/spatial/cell2location/` |

`01_analysis.R` declares each panel's input table and required columns. It
performs lightweight panel assembly only; model fitting remains in
`workflows/`. `02_plot.R` renders standard vector panels and records
package-native or non-computational panels without fabricating a replacement.

## Run

```bash
Rscript figures/Fig04/01_analysis.R \
  --config figures/Fig04/config.yaml \
  --input-dir data/processed/Fig04 \
  --output-dir outputs/Fig04 \
  --seed 20260730 --threads 4

Rscript figures/Fig04/02_plot.R \
  --config figures/Fig04/config.yaml \
  --input-dir outputs/Fig04 \
  --output-dir outputs/Fig04 \
  --seed 20260730 --threads 4
```

Private patient tables and large objects are not distributed. The expected
de-identified table schemas are visible directly in `01_analysis.R`.
