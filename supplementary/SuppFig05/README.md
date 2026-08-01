# SuppFig05: Developmental trajectories define functionally and spatially distinct malignant epithelial states in UTUC

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | Adjacent-epithelial-reference inferCNV heatmap | `workflows/single_cell/02a_infercnv_adjacent_epithelial_reference.R` |
| B | Malignant epithelial UMAP | `workflows/single_cell/02a_infercnv_adjacent_epithelial_reference.R` |
| C | CytoTRACE2 and Monocle3 trajectories | `workflows/single_cell/04_cytotrace2.R -> workflows/single_cell/03b_monocle3_robustness.R` |
| D | Basal-marker density | `workflows/single_cell/01b_annotation_and_markers.R -> workflows/single_cell/08_marker_visualization.R` |
| E | Malignant-state spatial maps | `workflows/spatial/cell2location/` |
| F | Cancer_c0 and Cancer_c3 niche distribution | `workflows/spatial/cell2location/` |
| G | Cancer_c0 and Cancer_c3 DSS | `workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R` |
| H | Top malignant regulons | `workflows/single_cell/05_pyscenic.sh` |
| I | Cancer_c0 enrichment | `workflows/single_cell/06_functional_enrichment.R` |
| J | PROGENy activity | `workflows/single_cell/07_pathway_activity.R` |

`01_analysis.R` declares each panel's input table and required columns. It
performs lightweight panel assembly only; model fitting remains in
`workflows/`. `02_plot.R` renders standard vector panels and records
package-native or non-computational panels without fabricating a replacement.

## Run

```bash
Rscript supplementary/SuppFig05/01_analysis.R \
  --config supplementary/SuppFig05/config.yaml \
  --input-dir data/processed/SuppFig05 \
  --output-dir outputs/SuppFig05 \
  --seed 20260730 --threads 4

Rscript supplementary/SuppFig05/02_plot.R \
  --config supplementary/SuppFig05/config.yaml \
  --input-dir outputs/SuppFig05 \
  --output-dir outputs/SuppFig05 \
  --seed 20260730 --threads 4
```

Private patient tables and large objects are not distributed. The expected
de-identified table schemas are visible directly in `01_analysis.R`.
