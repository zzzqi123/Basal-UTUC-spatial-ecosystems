# Fig01: Molecular subtype, pathological stage, and the tumor microenvironment in UTUC

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | Molecular subtype distribution by stage | `workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R` |
| B | Subtype-stratified disease-specific survival | `workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R` |
| C | Immune and stromal scores within stage | `workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R` |
| D | Single-cell UMAP of major lineages | `workflows/single_cell/01_process_scrna.R` |
| E | Representative lineage-marker dot plot | `workflows/single_cell/01b_annotation_and_markers.R -> workflows/single_cell/08_marker_visualization.R` |
| F | Relative enrichment of major cell types | `workflows/single_cell/09_roe_composition.R` |

`01_analysis.R` records each panel's source workflow, input table and required
columns. `02_plot.R` draws the standard vector panels; panels exported directly
from an analysis package or generated experimentally are listed in the panel
map.

## Run

```bash
Rscript figures/Fig01/01_analysis.R \
  --config figures/Fig01/config.yaml \
  --input-dir data/processed/Fig01 \
  --output-dir outputs/Fig01 \
  --seed 20260730 --threads 4

Rscript figures/Fig01/02_plot.R \
  --config figures/Fig01/config.yaml \
  --input-dir outputs/Fig01 \
  --output-dir outputs/Fig01 \
  --seed 20260730 --threads 4
```

Required input columns are listed directly in `01_analysis.R`; expected files
are listed in `expected_outputs.txt`.
