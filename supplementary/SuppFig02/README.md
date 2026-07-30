# SuppFig02: Single-cell QC and annotation

## Panels

`A-C`

## Analysis

QC metrics, lineage markers and major cell-type proportions.

The analysis script validates the expected input schema and calls the shared
project workflow. Method-specific implementations are stored under `methods/`
and project-authored helpers under `functions/`.

## Run order

```bash
Rscript supplementary/SuppFig02/01_analysis.R \
  --config supplementary/SuppFig02/config.yaml \
  --input-dir data/processed \
  --output-dir outputs/SuppFig02 \
  --seed 20260730 --threads 4

Rscript supplementary/SuppFig02/02_plot.R \
  --config supplementary/SuppFig02/config.yaml \
  --input-dir outputs/SuppFig02 \
  --output-dir outputs/SuppFig02 \
  --seed 20260730 --threads 4
```

Inputs containing patient-level or large binary data are local and are not
distributed in Git. See `data/README.md`.
