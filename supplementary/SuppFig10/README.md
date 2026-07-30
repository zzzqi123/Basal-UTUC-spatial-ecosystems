# SuppFig10: Mesenchymal and endothelial heterogeneity

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | Mesenchymal markers and GO terms | `workflows/single_cell/06_functional_enrichment.R` |
| B | Spatial myogenesis score | `workflows/spatial/09_spacet_gene_set_scores.R` |
| C | CAF_c3_FAP Hallmark enrichment | `workflows/single_cell/06_functional_enrichment.R` |
| D | Endothelial UMAP | `workflows/single_cell/01c_lineage_subclustering.R` |
| E | Endothelial marker dot plot | `workflows/single_cell/01b_annotation_and_markers.R -> workflows/single_cell/08_marker_visualization.R` |
| F | Endo_c1_CXCR4 enrichment | `workflows/single_cell/06_functional_enrichment.R` |
| G | Stromal and endothelial DSS | `workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R` |

`01_analysis.R` declares each panel's input table and required columns. It
performs lightweight panel assembly only; model fitting remains in
`workflows/`. `02_plot.R` renders standard vector panels and records
package-native or non-computational panels without fabricating a replacement.

## Run

```bash
Rscript supplementary/SuppFig10/01_analysis.R \
  --config supplementary/SuppFig10/config.yaml \
  --input-dir data/processed/SuppFig10 \
  --output-dir outputs/SuppFig10 \
  --seed 20260730 --threads 4

Rscript supplementary/SuppFig10/02_plot.R \
  --config supplementary/SuppFig10/config.yaml \
  --input-dir outputs/SuppFig10 \
  --output-dir outputs/SuppFig10 \
  --seed 20260730 --threads 4
```

Private patient tables and large objects are not distributed. The expected
de-identified table schemas are visible directly in `01_analysis.R`.
