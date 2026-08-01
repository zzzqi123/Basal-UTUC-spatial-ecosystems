# SuppFig03: Integration of UTUC GWAS signals with single-cell transcriptomic profiles using scPagwas

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | Annotated single-cell t-SNE | `workflows/single_cell/01_process_scrna.R` |
| B | Cell-level scPagwas adjusted FDR | `workflows/genetics/01_scpagwas.R -> workflows/genetics/02_prepare_scpagwas_tables.R` |
| C | Cell-type scPagwas bootstrap FDR | `workflows/genetics/01_scpagwas.R -> workflows/genetics/02_prepare_scpagwas_tables.R` |

`01_analysis.R` declares each panel's input table and required columns. It
performs lightweight panel assembly only; model fitting remains in
`workflows/`. `02_plot.R` renders standard vector panels and records
package-native or non-computational panels without fabricating a replacement.

## Run

```bash
Rscript supplementary/SuppFig03/01_analysis.R \
  --config supplementary/SuppFig03/config.yaml \
  --input-dir data/processed/SuppFig03 \
  --output-dir outputs/SuppFig03 \
  --seed 20260730 --threads 4

Rscript supplementary/SuppFig03/02_plot.R \
  --config supplementary/SuppFig03/config.yaml \
  --input-dir outputs/SuppFig03 \
  --output-dir outputs/SuppFig03 \
  --seed 20260730 --threads 4
```

Private patient tables and large objects are not distributed. The expected
de-identified table schemas are visible directly in `01_analysis.R`.
