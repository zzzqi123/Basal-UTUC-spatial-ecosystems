# cell2location workflow

This directory implements the official two-stage cell2location workflow with
the parameters reported for this study.

## Order

1. `01_reference_signatures.py` estimates cell-state reference signatures.
2. `02_spatial_mapping.py` trains the spatial mapping model for 50,000 epochs.
3. `03_export_abundance.py` exports posterior mean, q05 and q95 abundance.
4. `04_spatial_niches.py` constructs the q05 abundance graph and Leiden niches.

Both single-cell and spatial inputs must contain untransformed integer-like
counts. The scripts stop rather than silently use log-normalised values.

The q05 estimate is used for conservative spatial maps and pair burden.
Posterior means are reserved for the continuous boundary profiles in Figure 10
and Supplementary Figure S13.

