# Fig03: Stage-associated remodeling of the myeloid compartment

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

`01_analysis.R` declares each panel's input table and required columns. It
performs lightweight panel assembly only; model fitting remains in
`workflows/`. `02_plot.R` renders standard vector panels and records
package-native or non-computational panels without fabricating a replacement.

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

Private patient tables and large objects are not distributed. The expected
de-identified table schemas are visible directly in `01_analysis.R`.
