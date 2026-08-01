# SuppFig06: Developmental trajectories, transcriptional programs, spatial organization, and clinical association of malignant epithelial subclusters

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | Top markers and GO terms | `workflows/single_cell/06_functional_enrichment.R` |
| B | Monocle2 DDRTree malignant trajectory | `workflows/single_cell/03_trajectory_analysis.R` |
| C | Monocle3 robustness embeddings | `workflows/single_cell/03b_monocle3_robustness.R` |
| D | Representative regulon activities | `workflows/single_cell/05_pyscenic.sh` |
| E | Cancer_c3 Hallmark enrichment | `workflows/single_cell/06_functional_enrichment.R` |
| F | Section-specific Cancer_c3 boundary profiles | `workflows/spatial/03_prepare_boundary_input.py -> workflows/spatial/04_infer_boundary_stgrads.R -> workflows/spatial/05_boundary_profiles.R` |
| G | Malignant programs along the external Basal-luminal continuum | `workflows/spatial/06_rctd_deconvolution.R -> workflows/spatial/11a_prepare_external_visium_scores.R -> workflows/spatial/11_external_visium_basal_axis.R` |
| H | Japan-UTUC Cancer_c3 muscle-invasion models | `workflows/bulk_clinical_validation/02_japan_utuc_validation.R` |

`01_analysis.R` records each panel's source workflow, input table and required
columns. `02_plot.R` draws the standard vector panels; panels exported directly
from an analysis package or generated experimentally are listed in the panel
map.

## Run

```bash
Rscript supplementary/SuppFig06/01_analysis.R \
  --config supplementary/SuppFig06/config.yaml \
  --input-dir data/processed/SuppFig06 \
  --output-dir outputs/SuppFig06 \
  --seed 20260730 --threads 4

Rscript supplementary/SuppFig06/02_plot.R \
  --config supplementary/SuppFig06/config.yaml \
  --input-dir outputs/SuppFig06 \
  --output-dir outputs/SuppFig06 \
  --seed 20260730 --threads 4
```

Required input columns are listed directly in `01_analysis.R`; expected files
are listed in `expected_outputs.txt`.
