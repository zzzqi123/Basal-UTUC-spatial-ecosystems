# Spatial transcriptomic workflows

- `01_visium_preprocessing.R`: reads Space Ranger outputs and prepares Visium
  sections while retaining raw counts.
- `cell2location/`: reference signatures, spatial mapping, posterior export and
  q05 abundance niches.
- `02_multiscale_pair_burden.py`: density-scaled q05 pair burden at Visium
  graph rings 0–2 and 500 within-section positional permutations.
- `03_prepare_boundary_input.py`: posterior-mean malignant fraction,
  section-specific Otsu threshold and normalized coordinates.
- `04_infer_boundary_stgrads.R`: stGrads 2.0 signed-distance interface.
- `05_boundary_profiles.R`: section-specific GAM profiles fitted to binned
  medians from −6 to +6 spot spacings.
- `06_external_rctd.R`: full-mode RCTD for the external BLCA Visium cohort.

Conservative spatial maps and pair burden use q05 abundance. Continuous
boundary profiles use posterior means. Analyses are performed within section;
the discovery set is not treated as a patient-level stage test.

Japan-UTUC is not part of this directory. Its bulk deconvolution and clinical
models are in `../bulk_clinical_validation/`.
