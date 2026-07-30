# SuppFig13: Cancer_c3 boundary analysis and independent Japan-UTUC association

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | Tumor threshold, boundary and signed-distance definition | `workflows/spatial/03_prepare_boundary_input.py -> workflows/spatial/04_infer_boundary_stgrads.R -> workflows/spatial/05_boundary_profiles.R` |
| B | Section-specific Cancer_c3 boundary profiles | `workflows/spatial/03_prepare_boundary_input.py -> workflows/spatial/04_infer_boundary_stgrads.R -> workflows/spatial/05_boundary_profiles.R` |
| C | Japan-UTUC Cancer_c3 muscle-invasion models | `workflows/bulk_clinical_validation/02_japan_utuc_validation.R` |

`01_analysis.R` declares each panel's input table and required columns. It
performs lightweight panel assembly only; model fitting remains in
`workflows/`. `02_plot.R` renders standard vector panels and records
package-native or non-computational panels without fabricating a replacement.

## Run

```bash
Rscript supplementary/SuppFig13/01_analysis.R \
  --config supplementary/SuppFig13/config.yaml \
  --input-dir data/processed/SuppFig13 \
  --output-dir outputs/SuppFig13 \
  --seed 20260730 --threads 4

Rscript supplementary/SuppFig13/02_plot.R \
  --config supplementary/SuppFig13/config.yaml \
  --input-dir outputs/SuppFig13 \
  --output-dir outputs/SuppFig13 \
  --seed 20260730 --threads 4
```

Private patient tables and large objects are not distributed. The expected
de-identified table schemas are visible directly in `01_analysis.R`.
