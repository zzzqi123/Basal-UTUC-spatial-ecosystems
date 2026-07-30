# SuppFig04: Spatial analysis of Basal UTUC

## Panels

`A-D`

## Analysis

H&E, Leiden niches, cell2location maps and Basal score.

The analysis script validates the expected input schema and calls the shared
project workflow. Method-specific implementations are stored under `methods/`
and project-authored helpers under `functions/`.

## Run order

```bash
Rscript supplementary/SuppFig04/01_analysis.R \
  --config supplementary/SuppFig04/config.yaml \
  --input-dir data/processed \
  --output-dir outputs/SuppFig04 \
  --seed 20260730 --threads 4

Rscript supplementary/SuppFig04/02_plot.R \
  --config supplementary/SuppFig04/config.yaml \
  --input-dir outputs/SuppFig04 \
  --output-dir outputs/SuppFig04 \
  --seed 20260730 --threads 4
```

Inputs containing patient-level or large binary data are local and are not
distributed in Git. See `data/README.md`.

## Method source

Panels B-C are generated from `methods/cell2location/`. Spatial mapping is
locked to `N_cells_per_location=30`, `detection_alpha=20` and 50,000 epochs.
Panel C displays the q05 posterior abundance.
