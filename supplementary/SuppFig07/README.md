# SuppFig07: Myeloid subcluster characterisation

## Panels

`A-E`

## Analysis

Markers, GO, pseudotime density, spatial mapping and survival.

The analysis script validates the expected input schema and calls the shared
project workflow. Method-specific implementations are stored under `methods/`
and project-authored helpers under `functions/`.

## Run order

```bash
Rscript supplementary/SuppFig07/01_analysis.R \
  --config supplementary/SuppFig07/config.yaml \
  --input-dir data/processed \
  --output-dir outputs/SuppFig07 \
  --seed 20260730 --threads 4

Rscript supplementary/SuppFig07/02_plot.R \
  --config supplementary/SuppFig07/config.yaml \
  --input-dir outputs/SuppFig07 \
  --output-dir outputs/SuppFig07 \
  --seed 20260730 --threads 4
```

Inputs containing patient-level or large binary data are local and are not
distributed in Git. See `data/README.md`.
