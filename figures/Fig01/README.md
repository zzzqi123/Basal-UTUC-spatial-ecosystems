# Fig01: Subtype-stage relationships and cellular landscape

## Panels

`A-F`

## Analysis

Bulk subtype scores, survival summaries and cell composition.

The analysis script validates the expected input schema and calls the shared
project workflow. Method-specific implementations are stored under `methods/`
and project-authored helpers under `functions/`.

## Run order

```bash
Rscript figures/Fig01/01_analysis.R \
  --config figures/Fig01/config.yaml \
  --input-dir data/processed \
  --output-dir outputs/Fig01 \
  --seed 20260730 --threads 4

Rscript figures/Fig01/02_plot.R \
  --config figures/Fig01/config.yaml \
  --input-dir outputs/Fig01 \
  --output-dir outputs/Fig01 \
  --seed 20260730 --threads 4
```

Inputs containing patient-level or large binary data are local and are not
distributed in Git. See `data/README.md`.
