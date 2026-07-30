# SuppFig08: Lymphoid heterogeneity and spatial organization

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | Lymphoid UMAP | `workflows/single_cell/01_process_scrna.R` |
| B | CD4 functional programs | `workflows/single_cell/07_pathway_activity.R` |
| C | Lymphoid-state DSS | `workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R` |
| D | CD8 relative enrichment | `workflows/single_cell/01_process_scrna.R` |
| E | Spatial T-cell program scores | `workflows/spatial/01_visium_preprocessing.R` |

`01_analysis.R` declares each panel's input table and required columns. It
performs lightweight panel assembly only; model fitting remains in
`workflows/`. `02_plot.R` renders standard vector panels and records
package-native or non-computational panels without fabricating a replacement.

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

Private patient tables and large objects are not distributed. The expected
de-identified table schemas are visible directly in `01_analysis.R`.
