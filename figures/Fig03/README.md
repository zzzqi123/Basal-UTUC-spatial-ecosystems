# Fig03: Myeloid remodeling and high-risk states

## Panels

`A-I`

## Analysis

Myeloid Ro/e, trajectories, enrichment, co-localisation and survival.

The analysis script validates the expected input schema and calls the shared
project workflow. Method-specific implementations are stored under `methods/`
and project-authored helpers under `functions/`.

## Run order

```bash
Rscript figures/Fig03/01_analysis.R \
  --config figures/Fig03/config.yaml \
  --input-dir data/processed \
  --output-dir outputs/Fig03 \
  --seed 20260730 --threads 4

Rscript figures/Fig03/02_plot.R \
  --config figures/Fig03/config.yaml \
  --input-dir outputs/Fig03 \
  --output-dir outputs/Fig03 \
  --seed 20260730 --threads 4
```

Inputs containing patient-level or large binary data are local and are not
distributed in Git. See `data/README.md`.
