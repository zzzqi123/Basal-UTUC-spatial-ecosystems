# SuppFig03: GWAS integration with scRNA-seq

## Panels

`A-C`

## Analysis

Original scPagwas_main workflow with separated cell and cell-type FDR.

The analysis script validates the expected input schema and calls the shared
project workflow. Method-specific implementations are stored under `methods/`
and project-authored helpers under `functions/`.

## Run order

```bash
Rscript supplementary/SuppFig03/01_analysis.R \
  --config supplementary/SuppFig03/config.yaml \
  --input-dir data/processed \
  --output-dir outputs/SuppFig03 \
  --seed 20260730 --threads 4

Rscript supplementary/SuppFig03/02_plot.R \
  --config supplementary/SuppFig03/config.yaml \
  --input-dir outputs/SuppFig03 \
  --output-dir outputs/SuppFig03 \
  --seed 20260730 --threads 4
```

Inputs containing patient-level or large binary data are local and are not
distributed in Git. See `data/README.md`.

## Panel-to-method mapping

- A: annotated t-SNE coordinates from the single-cell object.
- B: cell-level `Random_Correct_BG_adjp` from 100 empirical random-background
  iterations.
- C: cell-type `bootstrap_results$bp_value` from 200 bootstrap iterations.

Run `methods/scPagwas/01_run_scpagwas.R` followed by
`methods/scPagwas/02_prepare_figure_tables.R`. The module is locked to
`scPagwas_main`, not `scPagwas_main2`.
