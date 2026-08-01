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

`01_analysis.R` records each panel's source workflow, input table and required
columns. `02_plot.R` draws the standard vector panels; panels exported directly
from an analysis package or generated experimentally are listed in the panel
map.

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

Required input columns are listed directly in `01_analysis.R`; expected files
are listed in `expected_outputs.txt`.
