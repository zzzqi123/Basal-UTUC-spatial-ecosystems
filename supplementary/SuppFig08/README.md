# SuppFig08: Lymphoid heterogeneity and spatial organisation

## Panels

`A-E`

## Analysis

UMAP, functional scores, survival, Ro/e and spatial T-cell scores.

The analysis script validates the expected input schema and calls the shared
project workflow. Method-specific implementations are stored under `methods/`
and project-authored helpers under `functions/`.

## Run order

```bash
Rscript supplementary/SuppFig08/01_analysis.R \
  --config supplementary/SuppFig08/config.yaml \
  --input-dir data/processed \
  --output-dir outputs/SuppFig08 \
  --seed 20260730 --threads 4

Rscript supplementary/SuppFig08/02_plot.R \
  --config supplementary/SuppFig08/config.yaml \
  --input-dir outputs/SuppFig08 \
  --output-dir outputs/SuppFig08 \
  --seed 20260730 --threads 4
```

Inputs containing patient-level or large binary data are local and are not
distributed in Git. See `data/README.md`.
