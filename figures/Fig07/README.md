# Fig07: External spatial validation of the myeloid-stromal program

## Panels

`A-I`

## Analysis

External BLCA spatial, single-cell and GeoMx validation.

The analysis script validates the expected input schema and calls the shared
project workflow. Method-specific implementations are stored under `methods/`
and project-authored helpers under `functions/`.

## Run order

```bash
Rscript figures/Fig07/01_analysis.R \
  --config figures/Fig07/config.yaml \
  --input-dir data/processed \
  --output-dir outputs/Fig07 \
  --seed 20260730 --threads 4

Rscript figures/Fig07/02_plot.R \
  --config figures/Fig07/config.yaml \
  --input-dir outputs/Fig07 \
  --output-dir outputs/Fig07 \
  --seed 20260730 --threads 4
```

Inputs containing patient-level or large binary data are local and are not
distributed in Git. See `data/README.md`.
