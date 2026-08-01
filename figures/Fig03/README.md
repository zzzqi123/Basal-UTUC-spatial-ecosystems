# Fig03: Myeloid-state heterogeneity and spatial remodeling across UTUC stages

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | Myeloid UMAP | `workflows/single_cell/01c_lineage_subclustering.R` |
| B | Myeloid relative enrichment by tissue group | `workflows/single_cell/09_roe_composition.R` |
| C | Monocyte-macrophage pseudotime | `workflows/single_cell/03_trajectory_analysis.R` |
| D | CCR2 monocyte and SPP1 TAM spatial co-localization | `workflows/spatial/07_cellstate_correlation_colocalization.R` |
| E | Spatial TAM M2 signature | `workflows/spatial/09_spacet_gene_set_scores.R` |
| F | Neutrophil UMAP | `workflows/single_cell/01c_lineage_subclustering.R` |
| G | VEGFA TAN and Cancer_c3 spatial co-localization | `workflows/spatial/07_cellstate_correlation_colocalization.R` |
| H | Myeloid-state survival curves | `workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R` |
| I | Neu_c2_VEGFA Hallmark enrichment | `workflows/single_cell/06_functional_enrichment.R` |

`01_analysis.R` records each panel's source workflow, input table and required
columns. `02_plot.R` draws the standard vector panels; panels exported directly
from an analysis package or generated experimentally are listed in the panel
map.

## Run

```bash
Rscript figures/Fig03/01_analysis.R \
  --config figures/Fig03/config.yaml \
  --input-dir data/processed/Fig03 \
  --output-dir outputs/Fig03 \
  --seed 20260730 --threads 4

Rscript figures/Fig03/02_plot.R \
  --config figures/Fig03/config.yaml \
  --input-dir outputs/Fig03 \
  --output-dir outputs/Fig03 \
  --seed 20260730 --threads 4
```

Required input columns are listed directly in `01_analysis.R`; expected files
are listed in `expected_outputs.txt`.
