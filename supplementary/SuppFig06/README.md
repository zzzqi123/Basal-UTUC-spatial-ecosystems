# SuppFig06: Malignant trajectories and clinical relevance

## Panels

`A-H`

## Analysis

Markers, GO, Monocle3, regulons, GSEA, correlations and survival.

The analysis script validates the expected input schema and calls the shared
project workflow. Method-specific implementations are stored under `methods/`
and project-authored helpers under `functions/`.

## Run order

```bash
Rscript supplementary/SuppFig06/01_analysis.R \
  --config supplementary/SuppFig06/config.yaml \
  --input-dir data/processed \
  --output-dir outputs/SuppFig06 \
  --seed 20260730 --threads 4

Rscript supplementary/SuppFig06/02_plot.R \
  --config supplementary/SuppFig06/config.yaml \
  --input-dir outputs/SuppFig06 \
  --output-dir outputs/SuppFig06 \
  --seed 20260730 --threads 4
```

Inputs containing patient-level or large binary data are local and are not
distributed in Git. See `data/README.md`.
