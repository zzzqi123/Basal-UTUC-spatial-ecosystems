# SuppFig01: Molecular subtype distribution and TME features

## Panels

`A-D`

## Analysis

Subtype distribution, purity, marker expression and cell composition.

The analysis script validates the expected input schema and calls the shared
project workflow. Method-specific implementations are stored under `methods/`
and project-authored helpers under `functions/`.

## Run order

```bash
Rscript supplementary/SuppFig01/01_analysis.R \
  --config supplementary/SuppFig01/config.yaml \
  --input-dir data/processed \
  --output-dir outputs/SuppFig01 \
  --seed 20260730 --threads 4

Rscript supplementary/SuppFig01/02_plot.R \
  --config supplementary/SuppFig01/config.yaml \
  --input-dir outputs/SuppFig01 \
  --output-dir outputs/SuppFig01 \
  --seed 20260730 --threads 4
```

Inputs containing patient-level or large binary data are local and are not
distributed in Git. See `data/README.md`.
