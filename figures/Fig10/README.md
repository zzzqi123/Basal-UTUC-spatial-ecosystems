# Fig10: Multiscale spatial organization and independent clinical validation

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | Section-level multiscale pair burden | `workflows/spatial/02_multiscale_pair_burden.py` |
| B | Permutation-based spatial observed-to-expected | `workflows/spatial/02_multiscale_pair_burden.py` |
| C | Section-specific signed-distance profiles | `workflows/spatial/03_prepare_boundary_input.py -> 04_infer_boundary_stgrads.R -> 05_boundary_profiles.R` |
| D | GSE319536 continuous Basal-luminal validation | `workflows/spatial/06_external_rctd.R` |
| E | Japan-UTUC cellular-program clinical models | `workflows/bulk_clinical_validation/02_japan_utuc_validation.R` |

`01_analysis.R` declares each panel's input table and required columns. It
performs lightweight panel assembly only; model fitting remains in
`workflows/`. `02_plot.R` renders standard vector panels and records
package-native or non-computational panels without fabricating a replacement.

## Run

```bash
Rscript figures/Fig10/01_analysis.R \
  --config figures/Fig10/config.yaml \
  --input-dir data/processed/Fig10 \
  --output-dir outputs/Fig10 \
  --seed 20260730 --threads 4

Rscript figures/Fig10/02_plot.R \
  --config figures/Fig10/config.yaml \
  --input-dir outputs/Fig10 \
  --output-dir outputs/Fig10 \
  --seed 20260730 --threads 4
```

Private patient tables and large objects are not distributed. The expected
de-identified table schemas are visible directly in `01_analysis.R`.
