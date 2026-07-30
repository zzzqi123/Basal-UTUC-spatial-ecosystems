# scPagwas workflow for Supplementary Figure S3

This module intentionally uses the original `scPagwas_main` entry point that
corresponds to the 2023 publication and the existing Supplementary Figure S3.
It does not silently replace the analysis with `scPagwas_main2`.

## Statistical outputs

- Cell-type table: `bootstrap_results$bp_value`, based on 200 bootstrap
  iterations and FDR adjustment by the package.
- Single-cell map: `Random_Correct_BG_adjp`, based on 100 random background
  iterations and Benjamini–Hochberg adjustment.

These quantities must not be interchanged. `02_prepare_scpagwas_tables.R` checks
their names and writes separate plotting tables.

The package, LD objects, pathway collection and build-matched block annotation
must be installed or supplied by the user. Third-party source code is not
vendored in this repository.

## SPP1 PheW-MR

`03_phewas_mr_spp1.R` validates and post-processes normalized output from the
official SMR/HEIDI software: 1,403 UK Biobank binary phenotypes, more than 500
cases, an expected 679 eligible outcomes, HEIDI p > 0.1 and BH FDR < 0.05.
The eQTL reference, UK Biobank summary statistics and third-party SMR binary
are not redistributed. See `../../config/phewas_mr.example.yaml`.
