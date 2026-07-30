#!/usr/bin/env python3
"""Generate the repeated, auditable figure-module interface files."""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

MODULES = {
    "figures/Fig01": (
        "A-F",
        "Subtype-stage relationships and cellular landscape",
        "group_summary",
        "Fig01_bulk_and_cellular_input.tsv",
        "subtype,stage",
        "stage",
        "ImmuneScore",
        "Bulk subtype scores, survival summaries and cell composition.",
    ),
    "figures/Fig02": (
        "A-C",
        "Basal UTUC spatial landscape across stages",
        "precomputed_results",
        "Fig02_spatial_summary.tsv",
        "sample,stage",
        "stage",
        "basal_score",
        "cell2location abundance, spatial correlations and IHC summary.",
    ),
    "figures/Fig03": (
        "A-I",
        "Myeloid remodeling and high-risk states",
        "group_summary",
        "Fig03_myeloid_results.tsv",
        "stage,cell_state",
        "cell_state",
        "value",
        "Myeloid Ro/e, trajectories, enrichment, co-localisation and survival.",
    ),
    "figures/Fig04": (
        "A-F",
        "Stromal and endothelial states",
        "group_summary",
        "Fig04_stromal_endothelial_results.tsv",
        "stage,cell_state",
        "cell_state",
        "value",
        "CAF/endothelial states, trajectories, spatial maps and correlations.",
    ),
    "figures/Fig05": (
        "A-H",
        "Global communication and candidate interactions",
        "precomputed_results",
        "cellchat_interactions.tsv",
        "source,target",
        "source",
        "probability",
        "CellChat global networks and selected SPP1/TGFB interactions.",
    ),
    "figures/Fig06": (
        "A-F",
        "SPP1+ TAM-FAP+ myCAF coupling",
        "precomputed_results",
        "Fig06_tam_mycaf_results.tsv",
        "analysis,panel",
        "analysis",
        "value",
        "Spatial coupling and NicheNet multi-ligand candidate network.",
    ),
    "figures/Fig07": (
        "A-I",
        "External spatial validation of the myeloid-stromal program",
        "group_summary",
        "Fig07_external_blca_results.tsv",
        "dataset,basal_luminal_group",
        "basal_luminal_group",
        "niche_score",
        "External BLCA spatial, single-cell and GeoMx validation.",
    ),
    "figures/Fig08": (
        "A-G",
        "Epithelial-intrinsic SPP1 perturbation and functional validation",
        "precomputed_results",
        "Fig08_spp1_perturbation_results.tsv",
        "analysis,term",
        "analysis",
        "value",
        "Epithelial scTenifoldKnk, enrichment and wet-lab summary.",
    ),
    "figures/Fig09": (
        "A-F",
        "VEGFA+ TAN-CXCR4+ tip EC angiogenic program",
        "precomputed_results",
        "Fig09_angiogenic_program_results.tsv",
        "analysis,panel",
        "analysis",
        "value",
        "CellChat, spatial coupling and multiplex IF summary.",
    ),
    "figures/Fig10": (
        "A-E",
        "Multiscale spatial burden and Japan-UTUC validation",
        "precomputed_results",
        "Fig10_multiscale_results.tsv",
        "sample,program,scale",
        "sample",
        "value",
        "q05 pair burden, spatial O/E, posterior-mean boundary profiles and clinical models.",
    ),
    "figures/Fig11": (
        "A-E",
        "Clinical SPP1-FAP validation",
        "group_summary",
        "Fig11_clinical_results.tsv",
        "analysis,group",
        "group",
        "value",
        "Correlation, ROC, survival and time-dependent AUC.",
    ),
    "supplementary/SuppFig01": (
        "A-D",
        "Molecular subtype distribution and TME features",
        "group_summary",
        "SuppFig01_bulk_tme.tsv",
        "stage,subtype",
        "subtype",
        "value",
        "Subtype distribution, purity, marker expression and cell composition.",
    ),
    "supplementary/SuppFig02": (
        "A-C",
        "Single-cell QC and annotation",
        "group_summary",
        "SuppFig02_scrna_qc.tsv",
        "sample,metric",
        "sample",
        "value",
        "QC metrics, lineage markers and major cell-type proportions.",
    ),
    "supplementary/SuppFig03": (
        "A-C",
        "GWAS integration with scRNA-seq",
        "precomputed_results",
        "SuppFig03_scpagwas_results.tsv",
        "cell_type,panel",
        "cell_type",
        "fdr",
        "Original scPagwas_main workflow with separated cell and cell-type FDR.",
    ),
    "supplementary/SuppFig04": (
        "A-D",
        "Spatial analysis of Basal UTUC",
        "precomputed_results",
        "SuppFig04_spatial_results.tsv",
        "sample,panel",
        "sample",
        "value",
        "H&E, Leiden niches, cell2location maps and Basal score.",
    ),
    "supplementary/SuppFig05": (
        "A-J",
        "Malignant epithelial states and spatial distribution",
        "precomputed_results",
        "SuppFig05_malignant_results.tsv",
        "analysis,cell_state",
        "analysis",
        "value",
        "inferCNV, CytoTRACE2, Monocle3, spatial mapping, survival, SCENIC, GSEA and PROGENy.",
    ),
    "supplementary/SuppFig06": (
        "A-H",
        "Malignant trajectories and clinical relevance",
        "precomputed_results",
        "SuppFig06_malignant_validation.tsv",
        "analysis,cell_state",
        "analysis",
        "value",
        "Markers, GO, Monocle3, regulons, GSEA, correlations and survival.",
    ),
    "supplementary/SuppFig07": (
        "A-E",
        "Myeloid subcluster characterisation",
        "precomputed_results",
        "SuppFig07_myeloid_results.tsv",
        "analysis,cell_state",
        "analysis",
        "value",
        "Markers, GO, pseudotime density, spatial mapping and survival.",
    ),
    "supplementary/SuppFig08": (
        "A-E",
        "Lymphoid heterogeneity and spatial organisation",
        "precomputed_results",
        "SuppFig08_lymphoid_results.tsv",
        "analysis,cell_state",
        "analysis",
        "value",
        "UMAP, functional scores, survival, Ro/e and spatial T-cell scores.",
    ),
    "supplementary/SuppFig09": (
        "A-H",
        "Lymphoid subcluster programs",
        "precomputed_results",
        "SuppFig09_lymphoid_programs.tsv",
        "analysis,cell_state",
        "analysis",
        "value",
        "CD4/CD8 markers, enrichment, B-cell survival and correlations.",
    ),
    "supplementary/SuppFig10": (
        "A-G",
        "Mesenchymal and endothelial heterogeneity",
        "precomputed_results",
        "SuppFig10_stromal_endothelial.tsv",
        "analysis,cell_state",
        "analysis",
        "value",
        "Markers, pathway enrichment, spatial scores and survival.",
    ),
    "supplementary/SuppFig11": (
        "A-E",
        "BLCA bulk validation",
        "group_summary",
        "SuppFig11_blca_bulk.tsv",
        "dataset,subtype",
        "subtype",
        "value",
        "ESTIMATE, expression, correlations, ROC and survival.",
    ),
    "supplementary/SuppFig12": (
        "A-F",
        "BLCA single-cell validation",
        "precomputed_results",
        "SuppFig12_blca_scrna.tsv",
        "analysis,cell_state",
        "analysis",
        "value",
        "Lineage annotation and SPP1/FAP/CXCR4 compartment reclustering.",
    ),
    "supplementary/SuppFig13": (
        "A-C",
        "Cancer_c3 boundary and Japan-UTUC validation",
        "precomputed_results",
        "SuppFig13_cancer_c3.tsv",
        "sample,analysis",
        "sample",
        "value",
        "Boundary definition, section-specific posterior-mean profiles and logistic models.",
    ),
}


ANALYSIS_TEMPLATE = """#!/usr/bin/env Rscript

source(file.path("functions", "R", "cli.R"))
source(file.path("functions", "R", "figure_workflows.R"))
opts <- parse_common_args()
cfg <- read_module_config(opts$config)
set.seed(opts$seed)
output <- run_configured_analysis("{module_id}", cfg, opts)
write_run_metadata(opts$output_dir, "{module_id}_analysis", opts, list(output = output))
"""

PLOT_TEMPLATE = """#!/usr/bin/env Rscript

source(file.path("functions", "R", "cli.R"))
source(file.path("functions", "R", "figure_workflows.R"))
opts <- parse_common_args()
cfg <- read_module_config(opts$config)
run_configured_plot("{module_id}", cfg, opts)
write_run_metadata(opts$output_dir, "{module_id}_plot", opts)
"""


def main() -> None:
    for relative, values in MODULES.items():
        panels, title, workflow, input_file, group_csv, x, y, description = values
        module_id = Path(relative).name
        directory = ROOT / relative
        directory.mkdir(parents=True, exist_ok=True)
        group_columns = [value.strip() for value in group_csv.split(",")]
        readme = f"""# {module_id}: {title}

## Panels

`{panels}`

## Analysis

{description}

The analysis script validates the expected input schema and calls the shared
project workflow. Method-specific implementations are stored under `methods/`
and project-authored helpers under `functions/`.

## Run order

```bash
Rscript {relative}/01_analysis.R \\
  --config {relative}/config.yaml \\
  --input-dir data/processed \\
  --output-dir outputs/{module_id} \\
  --seed 20260730 --threads 4

Rscript {relative}/02_plot.R \\
  --config {relative}/config.yaml \\
  --input-dir outputs/{module_id} \\
  --output-dir outputs/{module_id} \\
  --seed 20260730 --threads 4
```

Inputs containing patient-level or large binary data are local and are not
distributed in Git. See `data/README.md`.
"""
        config = [
            f"module: {module_id}",
            f"title: \"{title}\"",
            f"panels: \"{panels}\"",
            f"workflow: {workflow}",
            f"input_file: {input_file}",
            "group_columns:",
        ]
        config.extend(f"  - {value}" for value in group_columns)
        config.extend(
            [
                "required_columns:",
                f"  - {group_columns[0]}",
                f"  - {y}",
                "analysis_output: analysis_results.tsv",
                "plot_input: analysis_results.tsv",
                f"x: {x}",
                f"y: {y}",
                "color: null",
                f"title: \"{title}\"",
                "plot_output: figure_panels.pdf",
                "width: 7",
                "height: 5",
            ]
        )
        (directory / "README.md").write_text(readme, encoding="utf-8")
        (directory / "config.yaml").write_text("\n".join(config) + "\n", encoding="utf-8")
        (directory / "01_analysis.R").write_text(
            ANALYSIS_TEMPLATE.format(module_id=module_id), encoding="utf-8"
        )
        (directory / "02_plot.R").write_text(
            PLOT_TEMPLATE.format(module_id=module_id), encoding="utf-8"
        )
        (directory / "expected_outputs.txt").write_text(
            "analysis_results.tsv\nfigure_panels.pdf\nrun_metadata.yaml\n",
            encoding="utf-8",
        )


if __name__ == "__main__":
    main()

