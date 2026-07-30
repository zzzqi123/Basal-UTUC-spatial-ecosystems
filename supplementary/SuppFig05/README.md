# SuppFig05: Malignant epithelial states and spatial distribution

## Panels

`A-J`

## Analysis

inferCNV, CytoTRACE2, Monocle3, spatial mapping, survival, SCENIC, GSEA and PROGENy.

The analysis script validates the expected input schema and calls the shared
project workflow. Method-specific implementations are stored under `methods/`
and project-authored helpers under `functions/`.

## Run order

```bash
Rscript supplementary/SuppFig05/01_analysis.R \
  --config supplementary/SuppFig05/config.yaml \
  --input-dir data/processed \
  --output-dir outputs/SuppFig05 \
  --seed 20260730 --threads 4

Rscript supplementary/SuppFig05/02_plot.R \
  --config supplementary/SuppFig05/config.yaml \
  --input-dir outputs/SuppFig05 \
  --output-dir outputs/SuppFig05 \
  --seed 20260730 --threads 4
```

Inputs containing patient-level or large binary data are local and are not
distributed in Git. See `data/README.md`.

## Panel-to-method mapping

- A: `methods/single_cell/02_infercnv_non_epi_reference.R`.
- B-F: malignant cell states, trajectories and spatial abundance.
- G: survival analysis.
- H: `methods/single_cell/04_pyscenic.sh`.
- I-J: `methods/single_cell/05_functional_enrichment.R` and PROGENy output.
