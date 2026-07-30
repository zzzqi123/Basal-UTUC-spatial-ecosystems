# Fig08: Epithelial-intrinsic SPP1 perturbation and functional validation

## Panels

`A-G`

## Analysis

Epithelial scTenifoldKnk, enrichment and wet-lab summary.

The analysis script validates the expected input schema and calls the shared
project workflow. Method-specific implementations are stored under `methods/`
and project-authored helpers under `functions/`.

## Run order

```bash
Rscript figures/Fig08/01_analysis.R \
  --config figures/Fig08/config.yaml \
  --input-dir data/processed \
  --output-dir outputs/Fig08 \
  --seed 20260730 --threads 4

Rscript figures/Fig08/02_plot.R \
  --config figures/Fig08/config.yaml \
  --input-dir outputs/Fig08 \
  --output-dir outputs/Fig08 \
  --seed 20260730 --threads 4
```

Inputs containing patient-level or large binary data are local and are not
distributed in Git. See `data/README.md`.

## Method source

The computational perturbation is restricted to malignant epithelial cells and
is implemented in
`methods/communication_and_perturbation/03_spp1_virtual_knockout.R`. It is kept
separate from the macrophage-to-CAF candidate communication analysis.
