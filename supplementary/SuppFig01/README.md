# SuppFig01: Molecular subtype distribution and tumor microenvironment-related features across stages

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | Subtype distribution across stages | `workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R` |
| B | Tumor purity within stage | `workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R` |
| C | Immune, myeloid and stromal marker expression | `workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R` |
| D | Major-cell-type Sankey summary | `workflows/single_cell/01_process_scrna.R` |

`01_analysis.R` records each panel's source workflow, input table and required
columns. `02_plot.R` draws the standard vector panels; panels exported directly
from an analysis package or generated experimentally are listed in the panel
map.

## Run

```bash
Rscript supplementary/SuppFig01/01_analysis.R \
  --config supplementary/SuppFig01/config.yaml \
  --input-dir data/processed/SuppFig01 \
  --output-dir outputs/SuppFig01 \
  --seed 20260730 --threads 4

Rscript supplementary/SuppFig01/02_plot.R \
  --config supplementary/SuppFig01/config.yaml \
  --input-dir outputs/SuppFig01 \
  --output-dir outputs/SuppFig01 \
  --seed 20260730 --threads 4
```

Required input columns are listed directly in `01_analysis.R`; expected files
are listed in `expected_outputs.txt`.
