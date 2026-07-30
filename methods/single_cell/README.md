# Single-cell preprocessing

`01_process_scrna.R` contains the manuscript-level QC, normalisation, feature
selection, PCA and Harmony integration steps. Cell annotation, subclustering,
trajectory and enrichment analyses are separated into figure modules because
their cell subsets and outputs differ.

Large Seurat objects are local inputs and are intentionally excluded from Git.

