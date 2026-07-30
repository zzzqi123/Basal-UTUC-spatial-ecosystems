# Basal UTUC spatial ecosystems

Analytical code accompanying the manuscript:

> **SPP1-driven spatial niche remodeling defines aggressive progression in the Basal subtype of upper tract urothelial carcinoma**

This repository contains the curated code used to generate the bioinformatic
components of main Figures 1–11 and Supplementary Figures S1–S13. The code is
organised by figure so that reviewers can connect each panel to its analytical
inputs, parameters, intermediate tables and plotting script.

## Repository status

- Initial reviewer-facing release: `v0.1-reviewer`
- Manuscript parameters are treated as the release specification.
- Patient-level raw data and large derived objects are not distributed here.
- Public accession numbers and source URLs are listed in
  [`manifests/data_manifest.tsv`](manifests/data_manifest.tsv).
- Figure-to-code coverage is listed in
  [`manifests/figure_manifest.tsv`](manifests/figure_manifest.tsv).

## Organisation

```text
config/          portable example configuration and locked analysis parameters
manifests/       figure, data and Methods-to-code audit tables
methods/         reusable method workflows
functions/       project-authored R and Python helpers
figures/         one module for every main figure
supplementary/   one module for every supplementary figure
tests/           syntax, privacy, parameter and coverage checks
data/            data-access instructions only
```

Each figure module contains:

1. `README.md` with panel-to-script mapping and required inputs;
2. `01_analysis.R` or `01_analysis.py`;
3. `02_plot.R` or `02_plot.py`;
4. `config.yaml`;
5. `expected_outputs.txt`.

The small per-figure scripts intentionally call shared, tested workflows rather
than duplicating the same implementation in every directory.

This initial release separates computationally intensive method workflows from
panel assembly. Method directories contain the reusable model-fitting and
statistical implementations; figure directories document the panel mapping and
consume the resulting de-identified tables. Inputs that cannot be redistributed
are represented by explicit schemas and expected file names.

## Quick start

Create the portable configuration:

```bash
cp config/project.example.yaml config/project.yaml
```

Edit only the paths in `config/project.yaml`. Do not edit the locked scientific
parameters in `config/parameters.yaml` without updating the manuscript and
`manifests/method_code_checklist.tsv`.

Python environment:

```bash
conda env create -f environment.yml
conda activate basal-utuc-spatial
```

R packages:

```r
install.packages("renv")
renv::restore()
```

Run one module:

```bash
Rscript figures/Fig01/01_analysis.R \
  --config figures/Fig01/config.yaml \
  --input-dir data/processed \
  --output-dir outputs/Fig01 \
  --seed 20260730 \
  --threads 4
```

Run repository checks:

```bash
bash tests/run_all.sh
```

## Core method notes

### cell2location

The reference model uses `orig.ident` as the batch field and
`second_celltype_byhand` as the cell-state label. The reference regression is
trained for 250 epochs. Spatial mapping uses:

- `N_cells_per_location = 30`
- `detection_alpha = 20`
- `max_epochs = 50000`
- `batch_size = None`
- `train_size = 1`

Conservative spatial abundance maps and pair-burden analyses use the posterior
5% quantile (`q05_cell_abundance_w_sf`). Figure 10 boundary profiles use the
posterior mean and are explicitly labelled as such.

### scPagwas

Supplementary Figure S3 uses the original `scPagwas_main` workflow corresponding
to the 2023 method. Cell-type inference uses 200 bootstrap iterations with FDR
adjustment. Single-cell empirical-null inference uses 100 random background
iterations and Benjamini–Hochberg adjustment. Cell-level and cell-type FDR
columns are kept separate throughout the workflow.

## Data and privacy

This repository does not contain raw sequencing reads, patient-level clinical
records, Visium histology images, RDS/H5AD objects, model weights or server
environments. Private data are represented only by schemas and expected file
names. Public datasets must be obtained from their original repositories.

## Citation

See [`CITATION.cff`](CITATION.cff).

## Copyright

Copyright © 2026 Qi Zhang and co-authors. All rights reserved.

No open-source licence is granted. The repository is public for peer review,
academic inspection and reproducibility assessment. Third-party packages remain
subject to their respective licences.
