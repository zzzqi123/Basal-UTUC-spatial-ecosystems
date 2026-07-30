# SuppFig12: BLCA single-cell validation

## Panels

`A-F`

## Analysis

Lineage annotation and SPP1/FAP/CXCR4 compartment reclustering.

The analysis script validates the expected input schema and calls the shared
project workflow. Method-specific implementations are stored under `methods/`
and project-authored helpers under `functions/`.

## Run order

```bash
Rscript supplementary/SuppFig12/01_analysis.R \
  --config supplementary/SuppFig12/config.yaml \
  --input-dir data/processed \
  --output-dir outputs/SuppFig12 \
  --seed 20260730 --threads 4

Rscript supplementary/SuppFig12/02_plot.R \
  --config supplementary/SuppFig12/config.yaml \
  --input-dir outputs/SuppFig12 \
  --output-dir outputs/SuppFig12 \
  --seed 20260730 --threads 4
```

Inputs containing patient-level or large binary data are local and are not
distributed in Git. See `data/README.md`.
