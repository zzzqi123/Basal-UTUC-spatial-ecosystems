# Fig05: Global communication and candidate interactions

## Panels

`A-H`

## Analysis

CellChat global networks and selected SPP1/TGFB interactions.

The analysis script validates the expected input schema and calls the shared
project workflow. Method-specific implementations are stored under `methods/`
and project-authored helpers under `functions/`.

## Run order

```bash
Rscript figures/Fig05/01_analysis.R \
  --config figures/Fig05/config.yaml \
  --input-dir data/processed \
  --output-dir outputs/Fig05 \
  --seed 20260730 --threads 4

Rscript figures/Fig05/02_plot.R \
  --config figures/Fig05/config.yaml \
  --input-dir outputs/Fig05 \
  --output-dir outputs/Fig05 \
  --seed 20260730 --threads 4
```

Inputs containing patient-level or large binary data are local and are not
distributed in Git. See `data/README.md`.

## Method source

Run `methods/communication_and_perturbation/01_cellchat.R` before this module.
The workflow uses `CellChatDB.human`, excludes interactions supported by fewer
than 10 cells and retains the full interaction table before selecting the
SPP1/TGFB panels.
