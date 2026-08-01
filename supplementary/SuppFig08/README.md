# SuppFig08: Transcriptional heterogeneity and spatial organization of lymphoid subclusters in UTUC

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | Lymphoid UMAP | `workflows/single_cell/01c_lineage_subclustering.R` |
| B | CD4 functional programs | `workflows/single_cell/07_pathway_activity.R` |
| C | Lymphoid-state DSS | `workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R` |
| D | CD8 relative enrichment | `workflows/single_cell/09_roe_composition.R` |
| E | Spatial T-cell program scores | `workflows/spatial/09_spacet_gene_set_scores.R` |

`01_analysis.R` records each panel's source workflow, input table and required
columns. `02_plot.R` draws the standard vector panels; panels exported directly
from an analysis package or generated experimentally are listed in the panel
map.

## Run

```bash
Rscript supplementary/SuppFig08/01_analysis.R \
  --config supplementary/SuppFig08/config.yaml \
  --input-dir data/processed/SuppFig08 \
  --output-dir outputs/SuppFig08 \
  --seed 20260730 --threads 4

Rscript supplementary/SuppFig08/02_plot.R \
  --config supplementary/SuppFig08/config.yaml \
  --input-dir outputs/SuppFig08 \
  --output-dir outputs/SuppFig08 \
  --seed 20260730 --threads 4
```

Required input columns are listed directly in `01_analysis.R`; expected files
are listed in `expected_outputs.txt`.
