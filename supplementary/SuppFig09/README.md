# SuppFig09: Transcriptional and functional heterogeneity of lymphoid subclusters in UTUC

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | CD4 T-cell UMAP | `workflows/single_cell/01c_lineage_subclustering.R` |
| B | CD4 markers and functions | `workflows/single_cell/06_functional_enrichment.R` |
| C | CD4 relative enrichment | `workflows/single_cell/09_roe_composition.R` |
| D | CD8 T-cell UMAP | `workflows/single_cell/01c_lineage_subclustering.R` |
| E | CD8 markers and functions | `workflows/single_cell/06_functional_enrichment.R` |
| F | CD8 functional programs | `workflows/single_cell/07_pathway_activity.R` |
| G | B-cell DSS | `workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R` |
| H | Lymphoid-marker correlations | `workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R` |

`01_analysis.R` records each panel's source workflow, input table and required
columns. `02_plot.R` draws the standard vector panels; panels exported directly
from an analysis package or generated experimentally are listed in the panel
map.

## Run

```bash
Rscript supplementary/SuppFig09/01_analysis.R \
  --config supplementary/SuppFig09/config.yaml \
  --input-dir data/processed/SuppFig09 \
  --output-dir outputs/SuppFig09 \
  --seed 20260730 --threads 4

Rscript supplementary/SuppFig09/02_plot.R \
  --config supplementary/SuppFig09/config.yaml \
  --input-dir outputs/SuppFig09 \
  --output-dir outputs/SuppFig09 \
  --seed 20260730 --threads 4
```

Required input columns are listed directly in `01_analysis.R`; expected files
are listed in `expected_outputs.txt`.
