# Fig02: Basal UTUC spatial landscape across stages

## Panels

`A-C`

## Analysis

cell2location abundance, spatial correlations and IHC summary.

The analysis script validates the expected input schema and calls the shared
project workflow. Method-specific implementations are stored under `methods/`
and project-authored helpers under `functions/`.

## Run order

```bash
Rscript figures/Fig02/01_analysis.R \
  --config figures/Fig02/config.yaml \
  --input-dir data/processed \
  --output-dir outputs/Fig02 \
  --seed 20260730 --threads 4

Rscript figures/Fig02/02_plot.R \
  --config figures/Fig02/config.yaml \
  --input-dir outputs/Fig02 \
  --output-dir outputs/Fig02 \
  --seed 20260730 --threads 4
```

Inputs containing patient-level or large binary data are local and are not
distributed in Git. See `data/README.md`.

## Method source

Panels A-B use the four scripts in `methods/cell2location/`. Panel B uses
`q05_cell_abundance_w_sf`, 15 neighbours and Leiden resolution 0.3. Panel C is
an IHC summary and does not enter the cell2location model.
