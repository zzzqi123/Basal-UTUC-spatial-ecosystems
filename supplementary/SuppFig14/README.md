# SuppFig14: Tumor-boundary inference and functional characterization of spatial niches in Basal UTUC

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | Signed distance from the inferred tumor boundary | `workflows/spatial/03_prepare_boundary_input.py -> workflows/spatial/04_infer_boundary_stgrads.R -> workflows/spatial/05_boundary_profiles.R` |
| B | Integrated Hallmark GSEA for each spatial niche | `workflows/spatial/14_niche_functional_analysis.R` |
| C | Adjusted spatial niche-pathway associations in MI sections | `workflows/spatial/14_niche_functional_analysis.R` |

`01_analysis.R` declares each panel's input table and required columns. It
performs lightweight panel assembly only; model fitting remains in
`workflows/`. `02_plot.R` renders standard vector panels and records
package-native or non-computational panels without fabricating a replacement.

## Run

```bash
Rscript supplementary/SuppFig14/01_analysis.R \
  --config supplementary/SuppFig14/config.yaml \
  --input-dir data/processed/SuppFig14 \
  --output-dir outputs/SuppFig14 \
  --seed 20260730 --threads 4

Rscript supplementary/SuppFig14/02_plot.R \
  --config supplementary/SuppFig14/config.yaml \
  --input-dir outputs/SuppFig14 \
  --output-dir outputs/SuppFig14 \
  --seed 20260730 --threads 4
```

Private patient tables and large objects are not distributed. The expected
de-identified table schemas are visible directly in `01_analysis.R`.
