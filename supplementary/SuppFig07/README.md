# SuppFig07: Myeloid subcluster characterization

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | Canonical marker dot plot | `workflows/single_cell/01b_annotation_and_markers.R -> workflows/single_cell/08_marker_visualization.R` |
| B | Markers and GO terms | `workflows/single_cell/06_functional_enrichment.R` |
| C | Subcluster density along pseudotime | `workflows/single_cell/03_trajectory_analysis.R` |
| D | CCR2-SPP1 co-localization and M2 spatial scores | `workflows/spatial/07_cellstate_correlation_colocalization.R -> workflows/spatial/09_spacet_gene_set_scores.R` |
| E | Dendritic-cell DSS | `workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R` |

`01_analysis.R` declares each panel's input table and required columns. It
performs lightweight panel assembly only; model fitting remains in
`workflows/`. `02_plot.R` renders standard vector panels and records
package-native or non-computational panels without fabricating a replacement.

## Run

```bash
Rscript supplementary/SuppFig07/01_analysis.R \
  --config supplementary/SuppFig07/config.yaml \
  --input-dir data/processed/SuppFig07 \
  --output-dir outputs/SuppFig07 \
  --seed 20260730 --threads 4

Rscript supplementary/SuppFig07/02_plot.R \
  --config supplementary/SuppFig07/config.yaml \
  --input-dir outputs/SuppFig07 \
  --output-dir outputs/SuppFig07 \
  --seed 20260730 --threads 4
```

Private patient tables and large objects are not distributed. The expected
de-identified table schemas are visible directly in `01_analysis.R`.
