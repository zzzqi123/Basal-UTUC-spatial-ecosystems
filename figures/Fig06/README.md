# Fig06: SPP1 TAM-myCAF spatial coupling and candidate signaling

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | NMI-Basal spatial co-localization | `workflows/spatial/cell2location/` |
| B | MI-Basal spatial co-localization | `workflows/spatial/cell2location/` |
| C | Multiplex immunofluorescence | `non-computational source panel; code not applicable` |
| D | NicheNet multi-ligand candidate network | `workflows/communication/02_nichenet_tam_to_mycaf.R` |
| E | TGF-beta ligand-receptor spatial signal | `workflows/spatial/01_visium_preprocessing.R` |
| F | SPP1-integrin spatial signal | `workflows/spatial/01_visium_preprocessing.R` |

`01_analysis.R` declares each panel's input table and required columns. It
performs lightweight panel assembly only; model fitting remains in
`workflows/`. `02_plot.R` renders standard vector panels and records
package-native or non-computational panels without fabricating a replacement.

## Run

```bash
Rscript figures/Fig06/01_analysis.R \
  --config figures/Fig06/config.yaml \
  --input-dir data/processed/Fig06 \
  --output-dir outputs/Fig06 \
  --seed 20260730 --threads 4

Rscript figures/Fig06/02_plot.R \
  --config figures/Fig06/config.yaml \
  --input-dir outputs/Fig06 \
  --output-dir outputs/Fig06 \
  --seed 20260730 --threads 4
```

Private patient tables and large objects are not distributed. The expected
de-identified table schemas are visible directly in `01_analysis.R`.
