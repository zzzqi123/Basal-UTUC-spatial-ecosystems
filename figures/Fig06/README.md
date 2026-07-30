# Fig06: SPP1+ TAM-FAP+ myCAF coupling

## Panels

`A-F`

## Analysis

Spatial coupling and NicheNet multi-ligand candidate network.

The analysis script validates the expected input schema and calls the shared
project workflow. Method-specific implementations are stored under `methods/`
and project-authored helpers under `functions/`.

## Run order

```bash
Rscript figures/Fig06/01_analysis.R \
  --config figures/Fig06/config.yaml \
  --input-dir data/processed \
  --output-dir outputs/Fig06 \
  --seed 20260730 --threads 4

Rscript figures/Fig06/02_plot.R \
  --config figures/Fig06/config.yaml \
  --input-dir outputs/Fig06 \
  --output-dir outputs/Fig06 \
  --seed 20260730 --threads 4
```

Inputs containing patient-level or large binary data are local and are not
distributed in Git. See `data/README.md`.

## Method source

The ligand-ranking analysis is implemented in
`methods/communication_and_perturbation/02_nichenet_tam_to_mycaf.R`, with
`Macro_c0_SPP1` as sender and `CAF_c3_POSTN` as receiver. It reports a
multi-ligand candidate network and does not encode SPP1 as the sole causal
activator.
