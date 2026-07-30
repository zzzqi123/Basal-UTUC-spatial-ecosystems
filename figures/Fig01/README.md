# Fig01: Subtype-stage relationships and the cellular landscape

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | Molecular subtype distribution by stage | `workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R` |
| B | Subtype-stratified disease-specific survival | `workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R` |
| C | Immune and stromal scores within stage | `workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R` |
| D | Single-cell UMAP of major lineages | `workflows/single_cell/01_process_scrna.R` |
| E | Representative lineage-marker dot plot | `workflows/single_cell/01_process_scrna.R` |
| F | Relative enrichment of major cell types | `workflows/single_cell/01_process_scrna.R` |

`01_analysis.R` declares each panel's input table and required columns. It
performs lightweight panel assembly only; model fitting remains in
`workflows/`. `02_plot.R` renders standard vector panels and records
package-native or non-computational panels without fabricating a replacement.

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

Private patient tables and large objects are not distributed. The expected
de-identified table schemas are visible directly in `01_analysis.R`.
