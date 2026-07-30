# Fig09: VEGFA+ TAN-CXCR4+ tip EC angiogenic program

## Panels

`A-F`

## Analysis

CellChat, spatial coupling and multiplex IF summary.

The analysis script validates the expected input schema and calls the shared
project workflow. Method-specific implementations are stored under `methods/`
and project-authored helpers under `functions/`.

## Run order

```bash
Rscript figures/Fig09/01_analysis.R \
  --config figures/Fig09/config.yaml \
  --input-dir data/processed \
  --output-dir outputs/Fig09 \
  --seed 20260730 --threads 4

Rscript figures/Fig09/02_plot.R \
  --config figures/Fig09/config.yaml \
  --input-dir outputs/Fig09 \
  --output-dir outputs/Fig09 \
  --seed 20260730 --threads 4
```

Inputs containing patient-level or large binary data are local and are not
distributed in Git. See `data/README.md`.

## Method source

Selected communication is extracted from the global CellChat workflow with
`Neu_c2_VEGFA` and `Endo_c1_CXCR4` as the target cell-state pair. Spatial
co-localisation and multiplex IF are analysed independently of the CellChat
probability.
