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
