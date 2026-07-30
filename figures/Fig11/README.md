# Fig11: Clinical SPP1-FAP validation

## Panels

`A-E`

## Analysis

Correlation, ROC, survival and time-dependent AUC.

The analysis script validates the expected input schema and calls the shared
project workflow. Method-specific implementations are stored under `methods/`
and project-authored helpers under `functions/`.

## Run order

```bash
Rscript figures/Fig11/01_analysis.R \
  --config figures/Fig11/config.yaml \
  --input-dir data/processed \
  --output-dir outputs/Fig11 \
  --seed 20260730 --threads 4

Rscript figures/Fig11/02_plot.R \
  --config figures/Fig11/config.yaml \
  --input-dir outputs/Fig11 \
  --output-dir outputs/Fig11 \
  --seed 20260730 --threads 4
```

Inputs containing patient-level or large binary data are local and are not
distributed in Git. See `data/README.md`.
