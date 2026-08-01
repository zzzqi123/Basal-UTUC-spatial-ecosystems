# Basal UTUC spatial ecosystems

Reviewer-facing analysis code for the manuscript:

> **SPP1-associated spatial ecosystem remodeling in Basal upper tract
> urothelial carcinoma**

This repository provides the computational framework, project-authored
functions and figure-level code used in the study. Patient-level raw data,
large intermediate objects, histology images and private server environments
are not distributed.

## Repository structure

```text
Basal-UTUC-spatial-ecosystems/
├── core/
│   ├── R/                         shared R utilities
│   └── python/                    shared Python utilities
├── workflows/
│   ├── single_cell/               scRNA-seq processing and cell-state analyses
│   ├── spatial/                   spatial mapping and spatial-ecosystem analyses
│   ├── communication/             CellChat and NicheNet
│   ├── perturbation/              scTenifoldKnk perturbation analyses
│   ├── genetics/                  scPagwas and PheW-MR
│   └── bulk_clinical_validation/  subtype, survival and external validation
├── figures/Fig01-Fig11/           main-figure code organized by figure
├── supplementary/SuppFig01-SuppFig14/
│                                    supplementary-figure code organized by figure
├── config/                        shared and workflow-specific parameters
├── manifests/                     figure, method, function and data indexes
├── tests/                         automated repository checks
└── data/README.md                 local input contracts and access boundaries
```

## Article-level analysis workflow

This section describes the manuscript's analytical storyline—not a list of
software packages and not a replacement for the abstract.

The study asks how molecular subtype and pathological stage jointly shape the
UTUC tumor microenvironment, and how the Basal ecosystem is reorganized from
non-muscle-invasive to muscle-invasive disease.

```text
Subtype and stage definition
          ↓
Single-cell identification of epithelial, immune and stromal states
          ↓
Spatial reconstruction of the Basal tumor ecosystem
          ├── SPP1-associated TAM–myCAF boundary-like program
          └── VEGFA+ TAN–CXCR4+ tip-EC angiogenic program
          ↓
Communication and in-silico perturbation analyses
          ↓
External spatial, bulk and clinical validation
```

| Analytical question | Main code branch | Role in the manuscript |
|---|---|---|
| How do subtype and stage relate to the cellular composition of UTUC? | `workflows/bulk_clinical_validation/`, `workflows/single_cell/` | Defines the Basal immune–stromal background and resolves epithelial, myeloid, lymphoid, fibroblast and endothelial states. |
| Where are the relevant cell states organized in tissue? | `workflows/spatial/` | Maps cell-state abundance, spatial niches, co-localization, ligand–receptor neighborhoods and tumor-boundary profiles. |
| Which spatial programs distinguish NMI-Basal from MI-Basal disease? | `workflows/spatial/`, `workflows/communication/` | Quantifies the SPP1-associated TAM–myCAF program and the parallel VEGFA+ TAN–CXCR4+ tip-EC angiogenic program. |
| Which signaling and regulatory relationships are plausible? | `workflows/communication/`, `workflows/perturbation/` | Evaluates candidate communication networks and in-silico perturbations without treating them as source-specific functional proof. |
| Are these programs reproducible and clinically relevant? | `workflows/spatial/`, `workflows/bulk_clinical_validation/`, `workflows/genetics/` | Uses public bladder cancer spatial/single-cell datasets, GeoMx, Japan-UTUC bulk data and genetic analyses as separate validation layers. |

The two spatial programs are retained as related but distinct components of
Basal progression. SPP1 provides a longitudinal association across the Basal
phenotype, TAM–CAF spatial coupling, clinical outcome and epithelial-intrinsic
experiments; it is not presented as the sole driver of the parallel
angiogenic program. Japan-UTUC is a bulk clinical validation cohort and
supports patient-level cellular-program associations, not spatial location.

The executable order and input-output hand-offs are listed in
[`workflows/00_pipeline_overview.R`](workflows/00_pipeline_overview.R).

## Figure-level code

`figures/Fig01` through `figures/Fig11` and
`supplementary/SuppFig01` through `supplementary/SuppFig14` each contain:

- `README.md`: panel-to-workflow mapping and run order;
- `01_analysis.R`: panel input schema and analysis-table preparation;
- `02_plot.R`: vector plotting or an explicit package-native panel;
- `config.yaml`: figure-level settings;
- `expected_outputs.txt`: expected tables, plots and logs.

Non-computational microscopy and experimental panels are marked
`noncomputational`; the repository does not assign fabricated analysis code to
them.

## Reproducibility indexes

- [`manifests/figure_manifest.tsv`](manifests/figure_manifest.tsv): all 151
  panels across Fig.1–11 and Supplementary Fig.S1–S14.
- [`manifests/manuscript_method_audit.tsv`](manifests/manuscript_method_audit.tsv):
  line-by-line mapping from the manuscript Methods to public code.
- [`manifests/function_catalog.tsv`](manifests/function_catalog.tsv):
  project-authored R and Python functions.
- [`manifests/data_manifest.tsv`](manifests/data_manifest.tsv): public
  accessions, controlled inputs and expected local filenames.
- [`config/parameters.yaml`](config/parameters.yaml): shared
  manuscript-level parameters.
- [`DEPENDENCIES.md`](DEPENDENCIES.md): third-party packages, command-line
  tools and database requirements.

All public analysis scripts use the common interface:

```text
--config --input-dir --output-dir --seed --threads
```

Run metadata record the random seed, runtime version, UTC time and Git commit.

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
obtained from their original repositories; expected inputs are documented in
[`data/README.md`](data/README.md) and
[`manifests/data_manifest.tsv`](manifests/data_manifest.tsv).

No open-source licence is granted. Copyright © 2026 Qi Zhang and co-authors.
The repository is public for peer review, academic inspection and
reproducibility assessment. Third-party packages remain under their own
licences and their source code is not copied here.
