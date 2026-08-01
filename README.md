# Basal UTUC spatial ecosystems

Analysis code accompanying the manuscript:

> **SPP1-associated spatial ecosystem remodeling in Basal upper tract
> urothelial carcinoma**

The repository is organized by analysis layer and by final figure. It contains
the main processing workflows, shared R/Python functions, figure input
contracts and plotting scripts. Patient-level raw data, large intermediate
objects and histology images are kept outside the repository.

## Repository map

```text
Basal-UTUC-spatial-ecosystems/
├── core/
│   ├── R/                         shared R functions
│   └── python/                    shared Python functions
├── workflows/
│   ├── single_cell/               scRNA-seq processing and cell-state analyses
│   ├── spatial/                   spatial mapping, co-localization and boundaries
│   ├── genetics/                  scPagwas and SPP1 PheW-MR
│   └── bulk_clinical_validation/  subtype, deconvolution and clinical models
├── figures/Fig01-Fig11/           main-figure modules
├── supplementary/SuppFig01-SuppFig14/
│                                    supplementary-figure modules
├── config/                        analysis parameters and path templates
├── manifests/                     figure, method, function and data indexes
├── tests/                         syntax, parameter and privacy checks
└── data/README.md                 expected local inputs
```

## Study overview

We first asked whether molecular subtype or pathological stage primarily
shapes the UTUC tumor microenvironment. Basal tumors retained an
immune–stromal-enriched landscape in both NMI and MI disease, indicating that
subtype, rather than stage, is the dominant organizer of TME composition.

We then compared NMI-Basal and MI-Basal tumors to define the cellular and
spatial remodeling associated with muscle invasion. Two MI-associated programs
were prioritized:

- **Niche1: SPP1-associated immune–stromal program.** SPP1+ TAMs and FAP+
  myCAFs showed stronger invasive-front organization in MI-Basal sections,
  together with extracellular-matrix remodeling and reduced effector-immune
  activity toward the tumor. This line also includes epithelial SPP1 virtual
  knockout, J82/HUVEC experiments and external bladder cancer support.
- **Niche2: angiogenic program.** VEGFA+ TANs and CXCR4+ tip ECs showed an
  MI-associated spatial program linked to hypoxia and angiogenesis. Cancer_c3
  was evaluated as a related but separate malignant state.

Together, the Basal phenotype, invasive-front immune–stromal program,
epithelial-intrinsic experiments and SPP1/FAP classification and survival
analyses identify SPP1 as a candidate therapeutic target and prognostic
biomarker in Basal UTUC.

## Main-figure modules

| Figures | Analysis covered |
|---|---|
| [Fig. 1](figures/Fig01) | Molecular subtype, stage, bulk TME scores and major single-cell compartments |
| [Fig. 2](figures/Fig02) | Basal spatial transcriptomics and IHC across stages |
| [Fig. 3](figures/Fig03) | Myeloid states, trajectories and spatial remodeling |
| [Fig. 4](figures/Fig04) | Fibroblast and endothelial states |
| [Fig. 5](figures/Fig05) and [Fig. 6](figures/Fig06) | Cell communication and spatial organization of the SPP1+ TAM–FAP+ myCAF program |
| [Fig. 7](figures/Fig07) | External bladder cancer spatial, GeoMx and paired-Visium support |
| [Fig. 8](figures/Fig08) | Malignant-epithelial SPP1 perturbation and experimental panels |
| [Fig. 9](figures/Fig09) | VEGFA+ TAN–CXCR4+ tip-EC angiogenic program |
| [Fig. 10](figures/Fig10) | Multiscale spatial comparison and Japan-UTUC clinical models |
| [Fig. 11](figures/Fig11) | SPP1/FAP subtype classification and prognosis |

Each figure directory contains a panel-to-code table, the expected input
columns, plotting instructions, figure-specific configuration and a list of
outputs. The complete panel index, including Supplementary Figs. S1–S14, is in
[`manifests/figure_manifest.tsv`](manifests/figure_manifest.tsv).

## Analysis indexes

- [`workflows/00_pipeline_overview.R`](workflows/00_pipeline_overview.R):
  ordered list of workflow and figure hand-offs.
- [`manifests/method_index.tsv`](manifests/method_index.tsv):
  mapping from Methods sections to repository scripts.
- [`manifests/function_catalog.tsv`](manifests/function_catalog.tsv): shared R
  and Python functions written for this project.
- [`manifests/data_manifest.tsv`](manifests/data_manifest.tsv): data sources,
  accessions and expected local filenames.
- [`config/parameters.yaml`](config/parameters.yaml): parameters shared across
  workflows.
- [`DEPENDENCIES.md`](DEPENDENCIES.md): packages, command-line tools and
  external databases.

All analysis scripts use the same command-line arguments:

```text
--config --input-dir --output-dir --seed --threads
```

Run metadata include the random seed, software version, UTC time and Git
commit.

## Environment check

```bash
conda env create -f environment.yml
conda activate basal-utuc-spatial
bash tests/run_all.sh
```

The checks use temporary synthetic matrices created at run time. No patient or
spatial sample is bundled with the repository. Passing the checks confirms the
software environment, input schemas and code paths; it does not reproduce the
manuscript results without the datasets listed in `data/README.md`. Figure-level
commands and data requirements are documented in each figure directory.

## Data and code availability

FASTQ/BAM files, patient-level clinical records, RDS/H5AD/loom objects,
Visium histology images, model weights and local workstation/server paths are
not included. Public datasets should be downloaded from their original
repositories; filenames and input schemas are listed in
[`data/README.md`](data/README.md) and
[`manifests/data_manifest.tsv`](manifests/data_manifest.tsv).

No open-source licence is granted. Copyright © 2026 Qi Zhang and co-authors.
Third-party packages remain under their own licences and are not copied into
this repository.
