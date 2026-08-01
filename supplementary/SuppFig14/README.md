# SuppFig14: Tumor-boundary inference and functional characterization of spatial niches in Basal UTUC

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | Signed distance from the inferred tumor boundary | `workflows/spatial/03_prepare_boundary_input.py -> workflows/spatial/04_infer_boundary_stgrads.R -> workflows/spatial/05_boundary_profiles.R` |
| B | Integrated Hallmark GSEA for each spatial niche | `workflows/spatial/14_niche_functional_analysis.R` |
| C | Adjusted spatial niche-pathway associations in MI sections | `workflows/spatial/14_niche_functional_analysis.R` |

`01_analysis.R` records each panel's source workflow, input table and required
columns. `02_plot.R` draws the standard vector panels; panels exported directly
from an analysis package or generated experimentally are listed in the panel
map.

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

Required input columns are listed directly in `01_analysis.R`; expected files
are listed in `expected_outputs.txt`.
