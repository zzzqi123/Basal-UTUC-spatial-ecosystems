# Fig10: Multiscale spatial burden and Japan-UTUC validation

## Panels

`A-E`

## Analysis

q05 pair burden, spatial O/E, posterior-mean boundary profiles and clinical models.

The analysis script validates the expected input schema and calls the shared
project workflow. Method-specific implementations are stored under `methods/`
and project-authored helpers under `functions/`.

## Run order

```bash
Rscript figures/Fig10/01_analysis.R \
  --config figures/Fig10/config.yaml \
  --input-dir data/processed \
  --output-dir outputs/Fig10 \
  --seed 20260730 --threads 4

Rscript figures/Fig10/02_plot.R \
  --config figures/Fig10/config.yaml \
  --input-dir outputs/Fig10 \
  --output-dir outputs/Fig10 \
  --seed 20260730 --threads 4
```

Inputs containing patient-level or large binary data are local and are not
distributed in Git. See `data/README.md`.

## Panel-to-method mapping

- A: `methods/spatial_analysis/01_pair_burden.py`, q05 abundance, reported by
  section.
- B: multiscale spatial observed/expected values at ring 0, ring 1 and ring 2.
- C: `methods/spatial_analysis/02_boundary_profiles.R`, posterior mean,
  section-specific GAM curves without pooled spot-level inference.
- D: external GSE319536 multiscale validation.
- E: `methods/spatial_analysis/03_japan_clinical_models.R`, continuous
  cellular-program scores rather than spatial niche scores.
