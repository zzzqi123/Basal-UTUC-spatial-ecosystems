# Fig07: External bladder urothelial carcinoma datasets support the SPP1+ TAM-FAP+ myCAF program

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | Visium HD RCTD embedding | `workflows/spatial/06_external_rctd.R -> workflows/spatial/10_visiumhd_niche_colocalization.R` |
| B | Visium HD inferred cell-type map | `workflows/spatial/06_external_rctd.R -> workflows/spatial/10_visiumhd_niche_colocalization.R` |
| C | External SPP1 TAM-myCAF score | `workflows/spatial/06_external_rctd.R -> workflows/spatial/10_visiumhd_niche_colocalization.R` |
| D | Basal, luminal and component maps | `workflows/spatial/06_external_rctd.R -> workflows/spatial/10_visiumhd_niche_colocalization.R` |
| E | GeoMx component-score correlation | `workflows/spatial/12_geomx_roi_validation.R` |
| F | GeoMx cytotoxic-program associations | `workflows/spatial/12_geomx_roi_validation.R` |
| G | GeoMx suppressive-program associations | `workflows/spatial/12_geomx_roi_validation.R` |
| H | Paired Basal-high versus luminal-high comparison | `workflows/spatial/06_external_rctd.R -> workflows/spatial/11a_prepare_external_visium_scores.R -> workflows/spatial/11_external_visium_basal_axis.R` |
| I | Paired Visium validation maps | `workflows/spatial/06_external_rctd.R -> workflows/spatial/11a_prepare_external_visium_scores.R -> workflows/spatial/11_external_visium_basal_axis.R` |

`01_analysis.R` declares each panel's input table and required columns. It
performs lightweight panel assembly only; model fitting remains in
`workflows/`. `02_plot.R` renders standard vector panels and records
package-native or non-computational panels without fabricating a replacement.

## Run

```bash
Rscript figures/Fig07/01_analysis.R \
  --config figures/Fig07/config.yaml \
  --input-dir data/processed/Fig07 \
  --output-dir outputs/Fig07 \
  --seed 20260730 --threads 4

Rscript figures/Fig07/02_plot.R \
  --config figures/Fig07/config.yaml \
  --input-dir outputs/Fig07 \
  --output-dir outputs/Fig07 \
  --seed 20260730 --threads 4
```

Private patient tables and large objects are not distributed. The expected
de-identified table schemas are visible directly in `01_analysis.R`.
