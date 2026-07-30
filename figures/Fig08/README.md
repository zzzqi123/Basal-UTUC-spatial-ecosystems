# Fig08: Epithelial-intrinsic SPP1 perturbation and functional validation

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | Malignant-epithelial virtual-knockout enrichment | `workflows/perturbation/01_spp1_virtual_knockout.R` |
| B | SPP1 siRNA qRT-PCR | `non-computational source panel; code not applicable` |
| C | SPP1 knockdown western blot | `non-computational source panel; code not applicable` |
| D | J82 cell-viability assay | `non-computational source panel; code not applicable` |
| E | Transwell migration and invasion | `non-computational source panel; code not applicable` |
| F | Conditioned-medium tube-formation workflow | `non-computational source panel; code not applicable` |
| G | HUVEC tube-formation images and quantification | `non-computational source panel; code not applicable` |

`01_analysis.R` declares each panel's input table and required columns. It
performs lightweight panel assembly only; model fitting remains in
`workflows/`. `02_plot.R` renders standard vector panels and records
package-native or non-computational panels without fabricating a replacement.

## Run

```bash
Rscript figures/Fig08/01_analysis.R \
  --config figures/Fig08/config.yaml \
  --input-dir data/processed/Fig08 \
  --output-dir outputs/Fig08 \
  --seed 20260730 --threads 4

Rscript figures/Fig08/02_plot.R \
  --config figures/Fig08/config.yaml \
  --input-dir outputs/Fig08 \
  --output-dir outputs/Fig08 \
  --seed 20260730 --threads 4
```

Private patient tables and large objects are not distributed. The expected
de-identified table schemas are visible directly in `01_analysis.R`.
