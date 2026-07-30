# Basal UTUC spatial ecosystems

Reviewer-facing analysis code for the manuscript:

> **SPP1-associated spatial ecosystem remodeling in Basal upper tract
> urothelial carcinoma**

This repository explains how the computational analyses and bioinformatic
figure panels were produced without distributing patient-level raw data,
large intermediate objects, histology images or server environments.

## Four-layer organization

```text
core/            project-authored R and Python utilities
workflows/       article-level analysis framework and key parameters
figures/         main Figures 1–11, one directory per figure
supplementary/   Supplementary Figures S1–S13, one directory per figure
```

Supporting folders contain portable configuration, data-access instructions,
coverage manifests and automated checks.

### 1. Core utilities

`core/R/` and `core/python/` contain input validation, command-line parsing,
rank transforms, signature scoring, spatial pair burden, panel assembly,
plotting, vector export and run metadata. Every public function is indexed in
[`manifests/function_catalog.tsv`](manifests/function_catalog.tsv).

All analysis scripts accept:

```text
--config --input-dir --output-dir --seed --threads
```

Outputs are saved below the requested output directory together with the
random seed, software/runtime information and Git commit.

### 2. Article-level workflows

[`workflows/00_pipeline_overview.R`](workflows/00_pipeline_overview.R) records
the overall hand-off:

```text
bulk and clinical ─┐
single-cell ───────┼─> de-identified result tables ─> figure modules
genetics ──────────┤
spatial ───────────┤
communication ─────┤
perturbation ──────┘
```

The spatial branch includes Visium processing, cell2location, spatial
neighborhoods, multiscale pair burden, permutation O/E, stGrads boundaries,
section-specific GAM profiles and external RCTD. The independent Japan-UTUC
analysis is under `workflows/bulk_clinical_validation/`; it is not a spatial
dataset and its cellular-program scores do not measure spatial adjacency.

### 3. Main figures

`figures/Fig01` through `figures/Fig11` each contain:

- `README.md`: panel-to-workflow mapping and run order;
- `01_analysis.R`: explicit input table and column schema for every panel;
- `02_plot.R`: standard vector plotting or an explicit package-native panel;
- `config.yaml`: figure-level reproducibility settings;
- `expected_outputs.txt`: expected tables, plots and logs.

### 4. Supplementary figures

`supplementary/SuppFig01` through `supplementary/SuppFig13` use the same
interface. Non-computational microscopy or experimental panels are marked
`noncomputational`; they are not assigned fabricated analysis code.

The panel-level coverage table is
[`manifests/figure_manifest.tsv`](manifests/figure_manifest.tsv).

## Key manuscript-locked workflows

### cell2location

cell2location is located entirely under
[`workflows/spatial/cell2location/`](workflows/spatial/cell2location/).

- reference batch: `orig.ident`
- reference label: `second_celltype_byhand`
- reference regression: 250 epochs
- expected cells per location: 30
- detection alpha: 20
- spatial mapping: 50,000 epochs, `batch_size=None`, `train_size=1`
- conservative maps and pair burden: `q05_cell_abundance_w_sf`
- continuous boundary profiles: posterior mean, stated separately
- abundance neighbors: 15; Leiden resolution: 0.3

### scPagwas

Supplementary Figure S3 retains the original `scPagwas_main` workflow:

- cell-type inference: 200 bootstrap iterations followed by BH/FDR;
- single-cell inference: 100 random-background iterations;
- cell-level display: `Random_Correct_BG_adjp`;
- cell-type display: BH-adjusted `bootstrap_results$bp_value`.

The two FDR quantities are kept in separate tables and cannot be interchanged.

## Quick start

```bash
cp config/project.example.yaml config/project.yaml
conda env create -f environment.yml
conda activate basal-utuc-spatial
bash tests/run_all.sh
```

Example figure assembly:

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

## Data and intellectual-property boundary

The repository does not contain FASTQ/BAM files, patient-level clinical
records, RDS/H5AD/loom objects, Visium histology images, model weights, private
accessions, workstation paths or server paths. Public datasets must be
obtained from their original repositories; expected filenames are documented
in `manifests/data_manifest.tsv`.

No open-source licence is granted. Copyright © 2026 Qi Zhang and co-authors.
The repository is public for peer review, academic inspection and
reproducibility assessment. Third-party packages remain under their own
licences and their source code is not copied here.

## Official method interfaces

Public wrappers follow the documented interfaces of
[cell2location](https://cell2location.readthedocs.io/en/latest/notebooks/cell2location_tutorial.html),
[scPagwas](https://github.com/dengchunyu/scPagwas),
[CytoTRACE2](https://github.com/digitalcytometry/cytotrace2) and
[spacexr/RCTD](https://github.com/dmcable/spacexr). Study-specific parameters
are locked in `config/parameters.yaml` and
`manifests/method_code_checklist.tsv`; third-party package source is not
vendored into this repository.
