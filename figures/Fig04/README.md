# Fig04: Stromal and endothelial states

## Panels

`A-F`

## Analysis

CAF/endothelial states, trajectories, spatial maps and correlations.

The analysis script validates the expected input schema and calls the shared
project workflow. Method-specific implementations are stored under `methods/`
and project-authored helpers under `functions/`.

## Run order

```bash
Rscript figures/Fig04/01_analysis.R \
  --config figures/Fig04/config.yaml \
  --input-dir data/processed \
  --output-dir outputs/Fig04 \
  --seed 20260730 --threads 4

Rscript figures/Fig04/02_plot.R \
  --config figures/Fig04/config.yaml \
  --input-dir outputs/Fig04 \
  --output-dir outputs/Fig04 \
  --seed 20260730 --threads 4
```

Inputs containing patient-level or large binary data are local and are not
distributed in Git. See `data/README.md`.
