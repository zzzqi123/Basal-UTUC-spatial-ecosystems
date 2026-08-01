# Fig10: Multiscale spatial and clinical comparison of two microenvironmental programs in Basal UTUC

## Panel-to-code map

| Panel | Analysis | Source workflow |
|---|---|---|
| A | Section-level multiscale pair burden | `workflows/spatial/02_multiscale_pair_burden.py` |
| B | Permutation-based spatial observed-to-expected | `workflows/spatial/02_multiscale_pair_burden.py` |
| C | Section-specific signed-distance profiles | `workflows/spatial/03_prepare_boundary_input.py -> workflows/spatial/04_infer_boundary_stgrads.R -> workflows/spatial/05_boundary_profiles.R` |
| D | GSE319536 continuous Basal-luminal validation | `workflows/spatial/06_rctd_deconvolution.R -> workflows/spatial/11a_prepare_external_visium_scores.R -> workflows/spatial/11_external_visium_basal_axis.R` |
| E | Japan-UTUC cellular-program clinical models | `workflows/bulk_clinical_validation/02_japan_utuc_validation.R` |

`01_analysis.R` records each panel's source workflow, input table and required
columns. `02_plot.R` draws the standard vector panels; panels exported directly
from an analysis package or generated experimentally are listed in the panel
map.

## Data boundary

No example patient, spot-level or clinical table is included. Panels A-C use
the controlled institutional spatial dataset; panel D uses the public
GSE319536 series; panel E uses the controlled-access Japan-UTUC RNA-seq dataset
EGAD00001007667. The EGA dataset contains 158 UTUC tumors and 8 normal tissues;
the clinical models use the 158 tumors.

The figure module reads four upstream summary files:

| Panels | Required file | Produced by |
|---|---|---|
| A-B | `multiscale_pair_burden_and_oe.tsv` | `02_multiscale_pair_burden.py` |
| C | `section_boundary_predictions.tsv` | `05_boundary_profiles.R` |
| D | `external_visium_mean_gam_curves.tsv` | `11_external_visium_basal_axis.R` |
| E | `japan_utuc_clinical_models.tsv` | `02_japan_utuc_validation.R` |

Place these de-identified summary tables in one local input directory before
running the figure module. Their required columns are checked before plotting.

## Run

```bash
Rscript figures/Fig10/01_analysis.R \
  --config figures/Fig10/config.yaml \
  --input-dir data/processed/Fig10 \
  --output-dir outputs/Fig10 \
  --seed 20260730 --threads 4

Rscript figures/Fig10/02_plot.R \
  --config figures/Fig10/config.yaml \
  --input-dir outputs/Fig10 \
  --output-dir outputs/Fig10 \
  --seed 20260730 --threads 4
```

Required input columns are listed directly in `01_analysis.R`; expected files
are listed in `expected_outputs.txt`. `tests/test_fig10_assembly.R` creates
temporary synthetic tables and checks the complete table-to-PDF path; it does
not reproduce or approximate the biological results.
