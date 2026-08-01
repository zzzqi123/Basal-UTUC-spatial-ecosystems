#!/usr/bin/env python3
"""Rebuild the main and supplementary figure modules from the panel map."""

from __future__ import annotations

from dataclasses import dataclass
import csv
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]


@dataclass(frozen=True)
class Panel:
    panel: str
    title: str
    workflow: str
    columns: tuple[str, ...] = ()
    geometry: str | None = None
    fields: tuple[tuple[str, str], ...] = ()
    noncomputational: bool = False
    package_native: bool = False


@dataclass(frozen=True)
class Module:
    path: str
    title: str
    panels: tuple[Panel, ...]


def p(
    panel: str,
    title: str,
    workflow: str,
    columns: str,
    geometry: str | None,
    **fields: str,
) -> Panel:
    return Panel(
        panel,
        title,
        workflow,
        tuple(value.strip() for value in columns.split(",") if value.strip()),
        geometry,
        tuple(fields.items()),
    )


def native(panel: str, title: str, workflow: str, columns: str) -> Panel:
    return Panel(
        panel,
        title,
        workflow,
        tuple(value.strip() for value in columns.split(",") if value.strip()),
        package_native=True,
    )


def wet(panel: str, title: str) -> Panel:
    return Panel(
        panel,
        title,
        "non-computational source panel; code not applicable",
        noncomputational=True,
    )


BULK = (
    "workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> "
    "workflows/bulk_clinical_validation/01_subtype_clinical_analysis.R"
)
JAPAN = "workflows/bulk_clinical_validation/02_japan_utuc_validation.R"
BLCA = (
    "workflows/bulk_clinical_validation/00_prepare_bulk_scores.R -> "
    "workflows/bulk_clinical_validation/03_external_blca_validation.R"
)
SCRNA = "workflows/single_cell/01_process_scrna.R"
MARKERS = (
    "workflows/single_cell/01b_annotation_and_markers.R -> "
    "workflows/single_cell/08_marker_visualization.R"
)
SUBCLUSTER = "workflows/single_cell/01c_lineage_subclustering.R"
INFER_CNV_PRIMARY = "workflows/single_cell/02a_infercnv_adjacent_epithelial_reference.R"
INFER_CNV = "workflows/single_cell/02_infercnv_non_epi_reference.R"
INFER_CNV_ROBUST = "workflows/single_cell/02b_infercnv_reference_robustness.R"
TRAJECTORY = "workflows/single_cell/03_trajectory_analysis.R"
MONOCLE3 = "workflows/single_cell/03b_monocle3_robustness.R"
CYTOTRACE = "workflows/single_cell/04_cytotrace2.R"
SCENIC = "workflows/single_cell/05_pyscenic.sh"
ENRICHMENT = "workflows/single_cell/06_functional_enrichment.R"
PATHWAYS = "workflows/single_cell/07_pathway_activity.R"
ROE = "workflows/single_cell/09_roe_composition.R"
VISIUM = "workflows/spatial/01_visium_preprocessing.R"
C2L = "workflows/spatial/cell2location/"
PAIR = "workflows/spatial/02_multiscale_pair_burden.py"
BOUNDARY = (
    "workflows/spatial/03_prepare_boundary_input.py -> "
    "workflows/spatial/04_infer_boundary_stgrads.R -> "
    "workflows/spatial/05_boundary_profiles.R"
)
RCTD = "workflows/spatial/06_rctd_deconvolution.R"
SPATIAL_COLOC = "workflows/spatial/07_cellstate_correlation_colocalization.R"
SPAGENE = "workflows/spatial/08_spagene_lr_colocalization.R"
SPACET = "workflows/spatial/09_spacet_gene_set_scores.R"
VISIUMHD = (
    "workflows/spatial/06_rctd_deconvolution.R -> "
    "workflows/spatial/10_visiumhd_niche_colocalization.R"
)
EXTERNAL_VISIUM = (
    "workflows/spatial/06_rctd_deconvolution.R -> "
    "workflows/spatial/11a_prepare_external_visium_scores.R -> "
    "workflows/spatial/11_external_visium_basal_axis.R"
)
GEOMX = "workflows/spatial/12_geomx_roi_validation.R"
EFFECTOR_BOUNDARY = "workflows/spatial/13_effector_boundary_profiles.R"
NICHE_FUNCTION = "workflows/spatial/14_niche_functional_analysis.R"
CELLCHAT = "workflows/single_cell/11_cellchat.R"
NICHENET = "workflows/single_cell/12_nichenet_tam_to_mycaf.R"
SPATIAL_CELLCHAT = "workflows/spatial/15_cellchat_spatial.R"
PERTURB = "workflows/single_cell/10_spp1_virtual_knockout.R"
SCPAGWAS = (
    "workflows/genetics/01_scpagwas.R -> "
    "workflows/genetics/02_prepare_scpagwas_tables.R"
)


MODULES = (
    Module(
        "figures/Fig01",
        "Molecular subtype, pathological stage, and the tumor microenvironment in UTUC",
        (
            p("A", "Molecular subtype distribution by stage", BULK,
              "stage,subtype,n,proportion", "bar", x="stage", y="proportion", fill="subtype"),
            p("B", "Subtype-stratified disease-specific survival", BULK,
              "time,survival,subtype,endpoint", "line", x="time", y="survival", group="subtype", colour="subtype", facet="endpoint"),
            p("C", "Immune and stromal scores within stage", BULK,
              "stage,subtype,score_name,score_value", "box", x="subtype", y="score_value", fill="subtype", facet="score_name"),
            p("D", "Single-cell UMAP of major lineages", SCRNA,
              "UMAP_1,UMAP_2,major_celltype", "point", x="UMAP_1", y="UMAP_2", colour="major_celltype"),
            native("E", "Representative lineage-marker dot plot", MARKERS,
                   "cell_type,gene,average_expression,percent_expressing"),
            p("F", "Relative enrichment of major cell types", ROE,
              "sample_group,cell_type,roe", "heatmap", x="sample_group", y="cell_type", fill="roe"),
        ),
    ),
    Module(
        "figures/Fig02",
        "Spatial transcriptomic analysis and validation of Basal UTUC tumors across pathological stages",
        (
            p("A", "cell2location major-cell-type maps", C2L,
              "sample,x,y,cell_type,q05_abundance", "point", x="x", y="y", colour="q05_abundance", facet="cell_type"),
            p("B", "Within-section cell-state correlations", SPATIAL_COLOC,
              "sample,state_1,state_2,spearman_rho", "heatmap", x="state_1", y="state_2", fill="spearman_rho", facet="sample"),
            wet("C", "CK5/6, GATA3, FAP and SPP1 immunohistochemistry"),
        ),
    ),
    Module(
        "figures/Fig03",
        "Myeloid-state heterogeneity and spatial remodeling across UTUC stages",
        (
            p("A", "Myeloid UMAP", SUBCLUSTER,
              "UMAP_1,UMAP_2,cell_state", "point", x="UMAP_1", y="UMAP_2", colour="cell_state"),
            p("B", "Myeloid relative enrichment by tissue group", ROE,
              "sample_group,cell_state,roe", "heatmap", x="sample_group", y="cell_state", fill="roe"),
            p("C", "Monocyte-macrophage pseudotime", TRAJECTORY,
              "pseudotime,cell_state,density", "line", x="pseudotime", y="density", group="cell_state", colour="cell_state"),
            p("D", "CCR2 monocyte and SPP1 TAM spatial co-localization", SPATIAL_COLOC,
              "sample,x,y,pair_id,colocalization_score", "point", x="x", y="y", colour="colocalization_score", facet="pair_id"),
            p("E", "Spatial TAM M2 signature", SPACET,
              "sample,x,y,m2_score", "point", x="x", y="y", colour="m2_score", facet="sample"),
            p("F", "Neutrophil UMAP", SUBCLUSTER,
              "UMAP_1,UMAP_2,cell_state", "point", x="UMAP_1", y="UMAP_2", colour="cell_state"),
            p("G", "VEGFA TAN and Cancer_c3 spatial co-localization", SPATIAL_COLOC,
              "sample,x,y,pair_id,colocalization_score", "point", x="x", y="y", colour="colocalization_score", facet="pair_id"),
            p("H", "Myeloid-state survival curves", BULK,
              "time,survival,signature", "line", x="time", y="survival", group="signature", colour="signature"),
            p("I", "Neu_c2_VEGFA Hallmark enrichment", ENRICHMENT,
              "pathway,NES,FDR", "bar", x="pathway", y="NES", fill="NES"),
        ),
    ),
    Module(
        "figures/Fig04",
        "Functional states and spatial distribution of stromal and endothelial subclusters in UTUC",
        (
            p("A", "Mesenchymal UMAP", SUBCLUSTER,
              "UMAP_1,UMAP_2,cell_state", "point", x="UMAP_1", y="UMAP_2", colour="cell_state"),
            p("B", "Mesenchymal pseudotime branches", TRAJECTORY,
              "pseudotime,cell_state,density", "line", x="pseudotime", y="density", group="cell_state", colour="cell_state"),
            native("C", "CAF functional-state radar summary", PATHWAYS,
                   "cell_state,program,score"),
            p("D", "myCAF correlations with Basal and TGF-beta scores", PATHWAYS,
              "x_score,y_score,x_value,y_value", "point", x="x_value", y="y_value", colour="y_score", facet="x_score"),
            p("E", "Tip-cell correlations with myCAF and hypoxia", PATHWAYS,
              "x_score,y_score,x_value,y_value", "point", x="x_value", y="y_value", colour="y_score", facet="x_score"),
            p("F", "Stromal and endothelial spatial maps", C2L,
              "sample,x,y,cell_state,q05_abundance", "point", x="x", y="y", colour="q05_abundance", facet="cell_state"),
        ),
    ),
    Module(
        "figures/Fig05",
        "Global cell-cell communication and spatial mapping of SPP1+ TAM-FAP+ myCAF signaling in Basal UTUC",
        (
            native("A", "Number of inferred interactions", CELLCHAT,
                   "source,target,count"),
            native("B", "Aggregated interaction strength", CELLCHAT,
                   "source,target,weight"),
            p("C", "Outgoing and incoming communication centrality", CELLCHAT,
              "cell_state,outgoing,incoming", "point", x="outgoing", y="incoming", colour="cell_state"),
            native("D", "Selected SPP1 TAM-myCAF ligand-receptor probabilities", CELLCHAT,
                   "source,target,ligand,receptor,probability,p_value"),
            p("E", "TGFB1-(TGFBR1+TGFBR2) spatial signal", SPAGENE,
              "sample,x,y,interaction_score", "point", x="x", y="y", colour="interaction_score", facet="sample"),
            p("F", "SPP1-(ITGA8+ITGB1) spatial signal", SPAGENE,
              "sample,x,y,interaction_score", "point", x="x", y="y", colour="interaction_score", facet="sample"),
            native("G", "NMI-Basal SPP1 and TGF-beta spatial communication", SPATIAL_CELLCHAT,
                   "stage,pathway,source,target,probability,p_value"),
            native("H", "MI-Basal SPP1 and TGF-beta spatial communication", SPATIAL_CELLCHAT,
                   "stage,pathway,source,target,probability,p_value"),
        ),
    ),
    Module(
        "figures/Fig06",
        "Spatial organization and receiver programs of the SPP1+ TAM-FAP+ myCAF niche in Basal UTUC",
        (
            p("A", "NMI-Basal spatial co-localization", SPATIAL_COLOC,
              "sample,x,y,pair_id,colocalization_score", "point", x="x", y="y", colour="colocalization_score", facet="pair_id"),
            p("B", "MI-Basal spatial co-localization", SPATIAL_COLOC,
              "sample,x,y,pair_id,colocalization_score", "point", x="x", y="y", colour="colocalization_score", facet="pair_id"),
            wet("C", "Multiplex immunofluorescence"),
            native("D", "NicheNet macrophage-derived ligand activity", NICHENET,
                   "ligand,aupr_corrected,receiver_group"),
            native("E", "NicheNet ligand-receptor prior interaction potential", NICHENET,
                   "ligand,receptor,prior_interaction_potential"),
            native("F", "MI-associated FAP myCAF ligand-target potential", NICHENET,
                   "ligand,target,regulatory_potential"),
            p("G", "Effector-immune programs across Niche1-high boundaries", EFFECTOR_BOUNDARY,
              "sample,program,boundary_position,mean_score", "line", x="boundary_position", y="mean_score", group="sample", colour="sample", facet="program"),
            native("H", "FAP myCAF receiver-gene overlap across comparisons", NICHENET,
                   "gene_set,membership,count"),
        ),
    ),
    Module(
        "figures/Fig07",
        "External bladder urothelial carcinoma datasets support the SPP1+ TAM-FAP+ myCAF program",
        (
            p("A", "Visium HD RCTD embedding", VISIUMHD,
              "UMAP_1,UMAP_2,cell_type", "point", x="UMAP_1", y="UMAP_2", colour="cell_type"),
            p("B", "Visium HD inferred cell-type map", VISIUMHD,
              "x,y,cell_type,proportion", "point", x="x", y="y", colour="cell_type"),
            p("C", "External SPP1 TAM-myCAF score", VISIUMHD,
              "x,y,pair_score", "point", x="x", y="y", colour="pair_score"),
            p("D", "Basal, luminal and component maps", VISIUMHD,
              "x,y,feature,value", "point", x="x", y="y", colour="value", facet="feature"),
            p("E", "GeoMx component-score correlation", GEOMX,
              "spp1_tam_score,fap_mycaf_score,region", "point", x="spp1_tam_score", y="fap_mycaf_score", colour="region"),
            p("F", "GeoMx cytotoxic-program associations", GEOMX,
              "program,estimate,FDR", "bar", x="program", y="estimate", fill="estimate"),
            p("G", "GeoMx suppressive-program associations", GEOMX,
              "program,estimate,FDR", "bar", x="program", y="estimate", fill="estimate"),
            p("H", "Paired Basal-high versus luminal-high comparison", EXTERNAL_VISIUM,
              "sample,region_group,component,proportion", "box", x="region_group", y="proportion", fill="region_group", facet="component"),
            p("I", "Paired Visium validation maps", EXTERNAL_VISIUM,
              "sample,x,y,feature,value", "point", x="x", y="y", colour="value", facet="feature"),
        ),
    ),
    Module(
        "figures/Fig08",
        "Epithelial SPP1 expression and functional effects of SPP1 knockdown in a urothelial carcinoma model",
        (
            p("A", "SPP1 expression in adjacent and malignant epithelial cells", MARKERS,
              "UMAP_1,UMAP_2,tissue_group,SPP1", "point", x="UMAP_1", y="UMAP_2", colour="SPP1", facet="tissue_group"),
            p("B", "Malignant-epithelial virtual-knockout enrichment", PERTURB,
              "pathway,ontology,gene_count,FDR,neg_log10_FDR", "bar",
              x="pathway", y="neg_log10_FDR", fill="ontology"),
            wet("C", "SPP1 siRNA qRT-PCR"),
            wet("D", "SPP1 knockdown western blot"),
            wet("E", "J82 cell-viability assay"),
            wet("F", "Transwell migration and invasion"),
            wet("G", "Conditioned-medium HUVEC tube-formation assay"),
        ),
    ),
    Module(
        "figures/Fig09",
        "Spatial coupling and ligand-receptor interactions between CXCR4+ tip ECs and VEGFA+ TAN in Basal UTUC",
        (
            native("A", "Selected VEGFA TAN-tip EC ligand-receptor probabilities", CELLCHAT,
                   "source,target,ligand,receptor,probability,p_value"),
            p("B", "VEGFA-VEGFR1 spatial signal", SPAGENE,
              "sample,x,y,interaction_score", "point", x="x", y="y", colour="interaction_score", facet="sample"),
            p("C", "NAMPT-INSR spatial signal", SPAGENE,
              "sample,x,y,interaction_score", "point", x="x", y="y", colour="interaction_score", facet="sample"),
            p("D", "NMI-Basal VEGFA TAN-tip EC co-localization", SPATIAL_COLOC,
              "sample,x,y,pair_id,colocalization_score", "point", x="x", y="y", colour="colocalization_score", facet="pair_id"),
            p("E", "MI-Basal VEGFA TAN-tip EC co-localization", SPATIAL_COLOC,
              "sample,x,y,pair_id,colocalization_score", "point", x="x", y="y", colour="colocalization_score", facet="pair_id"),
            wet("F", "Multiplex immunofluorescence"),
        ),
    ),
    Module(
        "figures/Fig10",
        "Multiscale spatial and clinical comparison of two microenvironmental programs in Basal UTUC",
        (
            p("A", "Section-level multiscale pair burden", PAIR,
              "section,program,ring,pair_burden,fold_vs_nmi", "line", x="ring", y="fold_vs_nmi", group="section", colour="section", facet="program"),
            p("B", "Permutation-based spatial observed-to-expected", PAIR,
              "section,program,ring,spatial_oe,permutation_p_upper", "line", x="ring", y="spatial_oe", group="section", colour="section", facet="program"),
            p("C", "Section-specific signed-distance profiles", BOUNDARY,
              "sample,cell_state,signed_distance,fitted_z,se", "line", x="signed_distance", y="fitted_z", group="cell_state", colour="cell_state", facet="sample"),
            p("D", "GSE319536 continuous Basal-luminal validation", EXTERNAL_VISIUM,
              "basal_luminal_percentile,ring,pair_score,mean_curve,ci_low,ci_high", "line", x="basal_luminal_percentile", y="mean_curve", group="ring", colour="ring"),
            p("E", "Japan-UTUC cellular-program clinical models", JAPAN,
              "score,endpoint,model,effect,CI_low,CI_high,p_value,FDR_BH", "forest", effect="effect", term="score", lower="CI_low", upper="CI_high", facet="endpoint"),
        ),
    ),
    Module(
        "figures/Fig11",
        "Clinical stratification and subtype-discrimination performance of SPP1 and FAP in UTUC",
        (
            p("A", "DSS in Basal NMI versus Basal MI", BULK,
              "time,survival,stage", "line", x="time", y="survival", group="stage", colour="stage"),
            p("B", "SPP1 and FAP correlations with Basal score", BULK,
              "gene,expression,basal_score", "point", x="expression", y="basal_score", colour="gene", facet="gene"),
            p("C", "Subtype-classification ROC curves", BULK,
              "marker,fpr,tpr,auc", "line", x="fpr", y="tpr", group="marker", colour="marker"),
            p("D", "Joint SPP1-FAP survival stratification", BULK,
              "time,survival,group", "line", x="time", y="survival", group="group", colour="group"),
            p("E", "Time-dependent DSS AUC", BULK,
              "year,model,auc", "line", x="year", y="auc", group="model", colour="model"),
        ),
    ),
    Module(
        "supplementary/SuppFig01",
        "Molecular subtype distribution and tumor microenvironment-related features across stages",
        (
            p("A", "Subtype distribution across stages", BULK,
              "stage,subtype,n,proportion", "bar", x="stage", y="proportion", fill="subtype"),
            p("B", "Tumor purity within stage", BULK,
              "stage,subtype,purity", "box", x="subtype", y="purity", fill="subtype", facet="stage"),
            p("C", "Immune, myeloid and stromal marker expression", BULK,
              "stage,subtype,gene,expression", "box", x="subtype", y="expression", fill="subtype", facet="gene"),
            native("D", "Major-cell-type Sankey summary", SCRNA,
                   "sample_group,cell_type,n,proportion"),
        ),
    ),
    Module(
        "supplementary/SuppFig02",
        "Single-cell RNA sequencing quality control, marker validation, and cell-type composition",
        (
            p("A", "Single-cell quality-control metrics", SCRNA,
              "sample,metric,value", "box", x="sample", y="value", fill="sample", facet="metric"),
            p("B", "Lineage-marker density maps", MARKERS,
              "UMAP_1,UMAP_2,gene,expression", "point", x="UMAP_1", y="UMAP_2", colour="expression", facet="gene"),
            p("C", "Major-cell-type proportions", SCRNA,
              "sample_group,cell_type,proportion", "bar", x="sample_group", y="proportion", fill="cell_type"),
        ),
    ),
    Module(
        "supplementary/SuppFig03",
        "Integration of UTUC GWAS signals with single-cell transcriptomic profiles using scPagwas",
        (
            p("A", "Annotated single-cell t-SNE", SCRNA,
              "tSNE_1,tSNE_2,cell_type", "point", x="tSNE_1", y="tSNE_2", colour="cell_type"),
            p("B", "Cell-level scPagwas adjusted FDR", SCPAGWAS,
              "cell_id,tSNE_1,tSNE_2,Random_Correct_BG_adjp", "point", x="tSNE_1", y="tSNE_2", colour="Random_Correct_BG_adjp"),
            p("C", "Cell-type scPagwas bootstrap FDR", SCPAGWAS,
              "cell_type,bootstrap_bp_value,celltype_FDR", "bar", x="cell_type", y="celltype_FDR", fill="celltype_FDR"),
        ),
    ),
    Module(
        "supplementary/SuppFig04",
        "Spatial transcriptomic analysis of Basal UTUC across pathological stages",
        (
            wet("A", "H&E images of profiled sections"),
            p("B", "q05 abundance Leiden niches", C2L,
              "sample,x,y,spatial_niche", "point", x="x", y="y", colour="spatial_niche", facet="sample"),
            p("C", "cell2location cell-state maps", C2L,
              "sample,x,y,cell_state,q05_abundance", "point", x="x", y="y", colour="q05_abundance", facet="cell_state"),
            p("D", "Spatial Basal signature", VISIUM,
              "sample,x,y,basal_score", "point", x="x", y="y", colour="basal_score", facet="sample"),
        ),
    ),
    Module(
        "supplementary/SuppFig05",
        "Developmental trajectories define functionally and spatially distinct malignant epithelial states in UTUC",
        (
            native("A", "Adjacent-epithelial-reference inferCNV heatmap", INFER_CNV_PRIMARY,
                   "cell_id,chromosome,position,cnv_value"),
            p("B", "Malignant epithelial UMAP", INFER_CNV_PRIMARY,
              "UMAP_1,UMAP_2,cell_state", "point", x="UMAP_1", y="UMAP_2", colour="cell_state"),
            p("C", "CytoTRACE2 and Monocle3 trajectories", f"{CYTOTRACE} -> {MONOCLE3}",
              "embedding_1,embedding_2,analysis,value,cell_state", "point", x="embedding_1", y="embedding_2", colour="value", facet="analysis"),
            p("D", "Basal-marker density", MARKERS,
              "UMAP_1,UMAP_2,gene,expression", "point", x="UMAP_1", y="UMAP_2", colour="expression", facet="gene"),
            p("E", "Malignant-state spatial maps", C2L,
              "sample,x,y,cell_state,q05_abundance", "point", x="x", y="y", colour="q05_abundance", facet="cell_state"),
            p("F", "Cancer_c0 and Cancer_c3 niche distribution", C2L,
              "sample,spatial_niche,cell_state,median_abundance", "heatmap", x="spatial_niche", y="cell_state", fill="median_abundance", facet="sample"),
            p("G", "Cancer_c0 and Cancer_c3 DSS", BULK,
              "time,survival,signature", "line", x="time", y="survival", group="signature", colour="signature"),
            p("H", "Top malignant regulons", SCENIC,
              "cell_state,regulon,auc", "heatmap", x="cell_state", y="regulon", fill="auc"),
            p("I", "Cancer_c0 enrichment", ENRICHMENT,
              "pathway,NES,FDR", "bar", x="pathway", y="NES", fill="NES"),
            p("J", "PROGENy activity", PATHWAYS,
              "cell_state,pathway,activity", "heatmap", x="cell_state", y="pathway", fill="activity"),
        ),
    ),
    Module(
        "supplementary/SuppFig06",
        "Developmental trajectories, transcriptional programs, spatial organization, and clinical association of malignant epithelial subclusters",
        (
            p("A", "Top markers and GO terms", ENRICHMENT,
              "cell_state,gene_or_term,value,kind", "heatmap", x="cell_state", y="gene_or_term", fill="value", facet="kind"),
            native("B", "Monocle2 DDRTree malignant trajectory", TRAJECTORY,
                   "PCA_1,PCA_2,cell_state,pseudotime"),
            p("C", "Monocle3 robustness embeddings", MONOCLE3,
              "embedding_1,embedding_2,embedding,pseudotime", "point", x="embedding_1", y="embedding_2", colour="pseudotime", facet="embedding"),
            p("D", "Representative regulon activities", SCENIC,
              "cell_state,regulon,auc", "box", x="cell_state", y="auc", fill="cell_state", facet="regulon"),
            p("E", "Cancer_c3 Hallmark enrichment", ENRICHMENT,
              "pathway,NES,FDR", "bar", x="pathway", y="NES", fill="NES"),
            p("F", "Section-specific Cancer_c3 boundary profiles", BOUNDARY,
              "sample,cell_state,signed_distance,fitted_z,se", "line", x="signed_distance", y="fitted_z", group="sample", colour="sample"),
            p("G", "Malignant programs along the external Basal-luminal continuum", EXTERNAL_VISIUM,
              "cell_state,basal_luminal_percentile,mean_curve,ci_low,ci_high", "line", x="basal_luminal_percentile", y="mean_curve", group="cell_state", colour="cell_state"),
            p("H", "Japan-UTUC Cancer_c3 muscle-invasion models", JAPAN,
              "score,endpoint,model,effect,CI_low,CI_high,p_value,FDR_BH", "forest", effect="effect", term="model", lower="CI_low", upper="CI_high"),
        ),
    ),
    Module(
        "supplementary/SuppFig07",
        "Transcriptional and spatial characterization of myeloid subclusters in UTUC",
        (
            native("A", "Canonical marker dot plot", MARKERS,
                   "cell_state,gene,average_expression,percent_expressing"),
            p("B", "Markers and GO terms", ENRICHMENT,
              "cell_state,gene_or_term,value,kind", "heatmap", x="cell_state", y="gene_or_term", fill="value", facet="kind"),
            p("C", "Subcluster density along pseudotime", TRAJECTORY,
              "pseudotime,cell_state,density", "line", x="pseudotime", y="density", group="cell_state", colour="cell_state"),
            p("D", "CCR2-SPP1 co-localization and M2 spatial scores", f"{SPATIAL_COLOC} -> {SPACET}",
              "sample,x,y,feature,value", "point", x="x", y="y", colour="value", facet="feature"),
            p("E", "Dendritic-cell DSS", BULK,
              "time,survival,signature", "line", x="time", y="survival", group="signature", colour="signature"),
        ),
    ),
    Module(
        "supplementary/SuppFig08",
        "Transcriptional heterogeneity and spatial organization of lymphoid subclusters in UTUC",
        (
            p("A", "Lymphoid UMAP", SUBCLUSTER,
              "UMAP_1,UMAP_2,cell_state", "point", x="UMAP_1", y="UMAP_2", colour="cell_state"),
            p("B", "CD4 functional programs", PATHWAYS,
              "cell_state,program,score", "heatmap", x="cell_state", y="program", fill="score"),
            p("C", "Lymphoid-state DSS", BULK,
              "time,survival,signature", "line", x="time", y="survival", group="signature", colour="signature"),
            p("D", "CD8 relative enrichment", ROE,
              "sample_group,cell_state,roe", "heatmap", x="sample_group", y="cell_state", fill="roe"),
            p("E", "Spatial T-cell program scores", SPACET,
              "sample,x,y,program,score", "point", x="x", y="y", colour="score", facet="program"),
        ),
    ),
    Module(
        "supplementary/SuppFig09",
        "Transcriptional and functional heterogeneity of lymphoid subclusters in UTUC",
        (
            p("A", "CD4 T-cell UMAP", SUBCLUSTER,
              "UMAP_1,UMAP_2,cell_state", "point", x="UMAP_1", y="UMAP_2", colour="cell_state"),
            p("B", "CD4 markers and functions", ENRICHMENT,
              "cell_state,gene_or_term,value,kind", "heatmap", x="cell_state", y="gene_or_term", fill="value", facet="kind"),
            p("C", "CD4 relative enrichment", ROE,
              "sample_group,cell_state,roe", "heatmap", x="sample_group", y="cell_state", fill="roe"),
            p("D", "CD8 T-cell UMAP", SUBCLUSTER,
              "UMAP_1,UMAP_2,cell_state", "point", x="UMAP_1", y="UMAP_2", colour="cell_state"),
            p("E", "CD8 markers and functions", ENRICHMENT,
              "cell_state,gene_or_term,value,kind", "heatmap", x="cell_state", y="gene_or_term", fill="value", facet="kind"),
            p("F", "CD8 functional programs", PATHWAYS,
              "cell_state,program,score", "heatmap", x="cell_state", y="program", fill="score"),
            p("G", "B-cell DSS", BULK,
              "time,survival,signature", "line", x="time", y="survival", group="signature", colour="signature"),
            p("H", "Lymphoid-marker correlations", BULK,
              "signature,marker,rho", "heatmap", x="signature", y="marker", fill="rho"),
        ),
    ),
    Module(
        "supplementary/SuppFig10",
        "Transcriptional and spatial heterogeneity of mesenchymal and endothelial compartments in UTUC",
        (
            p("A", "Mesenchymal markers and GO terms", ENRICHMENT,
              "cell_state,gene_or_term,value,kind", "heatmap", x="cell_state", y="gene_or_term", fill="value", facet="kind"),
            p("B", "Spatial myogenesis score", SPACET,
              "sample,x,y,myogenesis_score", "point", x="x", y="y", colour="myogenesis_score"),
            p("C", "CAF_c3_FAP Hallmark enrichment", ENRICHMENT,
              "pathway,NES,FDR", "bar", x="pathway", y="NES", fill="NES"),
            p("D", "Endothelial UMAP", SUBCLUSTER,
              "UMAP_1,UMAP_2,cell_state", "point", x="UMAP_1", y="UMAP_2", colour="cell_state"),
            native("E", "Endothelial marker dot plot", MARKERS,
                   "cell_state,gene,average_expression,percent_expressing"),
            p("F", "Endo_c1_CXCR4 enrichment", ENRICHMENT,
              "pathway,NES,FDR", "bar", x="pathway", y="NES", fill="NES"),
            p("G", "Stromal and endothelial DSS", BULK,
              "time,survival,signature", "line", x="time", y="survival", group="signature", colour="signature"),
        ),
    ),
    Module(
        "supplementary/SuppFig11",
        "Bulk transcriptomic validation of the SPP1-associated Basal immune-stromal program in bladder urothelial carcinoma",
        (
            p("A", "Immune and stromal scores", BLCA,
              "stage,subtype,score_name,score_value", "box", x="subtype", y="score_value", fill="subtype", facet="score_name"),
            p("B", "FAP and SPP1 expression", BLCA,
              "stage,subtype,gene,expression", "box", x="subtype", y="expression", fill="subtype", facet="gene"),
            p("C", "SPP1 correlations", BLCA,
              "score_name,score_value,SPP1", "point", x="SPP1", y="score_value", facet="score_name"),
            p("D", "Subtype-classification ROC", BLCA,
              "marker,fpr,tpr,auc", "line", x="fpr", y="tpr", group="marker", colour="marker"),
            p("E", "External survival validation", BLCA,
              "time,survival,dataset,group", "line", x="time", y="survival", group="group", colour="group", facet="dataset"),
        ),
    ),
    Module(
        "supplementary/SuppFig12",
        "Single-cell validation of bladder urothelial carcinoma cell-type annotations and SPP1/FAP/CXCR4-associated compartments",
        (
            p("A", "Major-lineage UMAP", SCRNA,
              "UMAP_1,UMAP_2,cell_type", "point", x="UMAP_1", y="UMAP_2", colour="cell_type"),
            native("B", "Canonical lineage-marker dot plot", MARKERS,
                   "cell_type,gene,average_expression,percent_expressing"),
            native("C", "Neutrophil-marker audit", MARKERS,
                   "cell_type,gene,average_expression,percent_expressing"),
            p("D", "Myeloid reclustering and SPP1 density", f"{SUBCLUSTER} -> {MARKERS}",
              "UMAP_1,UMAP_2,cell_state,SPP1", "point", x="UMAP_1", y="UMAP_2", colour="SPP1"),
            p("E", "Fibroblast reclustering and FAP density", f"{SUBCLUSTER} -> {MARKERS}",
              "UMAP_1,UMAP_2,cell_state,FAP", "point", x="UMAP_1", y="UMAP_2", colour="FAP"),
            p("F", "Endothelial reclustering and CXCR4 density", f"{SUBCLUSTER} -> {MARKERS}",
              "UMAP_1,UMAP_2,cell_state,CXCR4", "point", x="UMAP_1", y="UMAP_2", colour="CXCR4"),
        ),
    ),
    Module(
        "supplementary/SuppFig13",
        "Robustness of malignant epithelial subcluster assignments and functional programs under alternative inferCNV reference selection",
        (
            native("A", "Original adjacent-epithelial-reference inferCNV heatmap", INFER_CNV_PRIMARY,
                   "cell_id,chromosome,position,cnv_value"),
            native("B", "Within-sample non-epithelial-reference inferCNV heatmap", INFER_CNV,
                   "cell_id,chromosome,position,cnv_value"),
            p("C", "Cell-level CNV burden percentile concordance", INFER_CNV_ROBUST,
              "cell_id,sample,primary_percentile,sensitivity_percentile", "point", x="primary_percentile", y="sensitivity_percentile", colour="sample"),
            p("D", "Patient-specific CNV burden rank correlations", INFER_CNV_ROBUST,
              "sample,n_cells,spearman_rho", "bar", x="sample", y="spearman_rho", fill="spearman_rho"),
            p("E", "Original and revised malignant-subcluster UMAPs", INFER_CNV_ROBUST,
              "cell_id,UMAP_1,UMAP_2,analysis,cell_state", "point", x="UMAP_1", y="UMAP_2", colour="cell_state", facet="analysis"),
            native("F", "Overlap of malignant cells under both references", INFER_CNV_ROBUST,
                   "primary_malignant,sensitivity_malignant,count"),
            p("G", "Malignant-subcluster marker-profile concordance", INFER_CNV_ROBUST,
              "primary_cluster,sensitivity_cluster,spearman_rho", "heatmap", x="primary_cluster", y="sensitivity_cluster", fill="spearman_rho"),
            p("H", "Cancer_c0 and Cancer_c3 Hallmark NES concordance", INFER_CNV_ROBUST,
              "cell_state,pathway,primary_NES,sensitivity_NES", "point", x="primary_NES", y="sensitivity_NES", colour="cell_state"),
        ),
    ),
    Module(
        "supplementary/SuppFig14",
        "Tumor-boundary inference and functional characterization of spatial niches in Basal UTUC",
        (
            p("A", "Signed distance from the inferred tumor boundary", BOUNDARY,
              "sample,x,y,tumor_type,tumor_interface_zone,signed_distance", "point", x="x", y="y", colour="signed_distance", facet="sample"),
            native("B", "Integrated Hallmark GSEA for each spatial niche", NICHE_FUNCTION,
                   "niche,pathway,NES,p_value,FDR"),
            p("C", "Adjusted spatial niche-pathway associations in MI sections", NICHE_FUNCTION,
              "niche,pathway,beta,CI_low,CI_high,p_value,FDR", "forest", effect="beta", term="pathway", lower="CI_low", upper="CI_high", facet="niche"),
        ),
    ),
)


def r_string(value: str) -> str:
    escaped = value.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def r_vector(values: tuple[str, ...]) -> str:
    return "c(" + ", ".join(r_string(value) for value in values) + ")"


def r_list(values: dict[str, Any]) -> str:
    parts = []
    for key, value in values.items():
        if value is None:
            parts.append(f"{key} = NULL")
        elif isinstance(value, tuple):
            parts.append(f"{key} = {r_vector(value)}")
        elif isinstance(value, (int, float)):
            parts.append(f"{key} = {value}")
        else:
            parts.append(f"{key} = {r_string(str(value))}")
    return "list(\n    " + ",\n    ".join(parts) + "\n  )"


def analysis_script(module: Module) -> str:
    records = []
    for panel in module.panels:
        values: dict[str, Any] = {
            "panel": panel.panel,
            "title": panel.title,
            "workflow": panel.workflow,
            "operation": "document_only" if panel.noncomputational else "select",
        }
        if not panel.noncomputational:
            values.update(
                {
                    "input": f"{Path(module.path).name}_{panel.panel}.tsv",
                    "required": panel.columns,
                    "output": f"panel_{panel.panel}_data.tsv",
                }
            )
        records.append(r_list(values))
    joined_records = ",\n  ".join(records)
    return f'''#!/usr/bin/env Rscript

# {Path(module.path).name}: {module.title}
# The source workflow for each panel is recorded in panel_plan. This script
# checks the exported columns and writes the tables used for figure assembly.

source(file.path("core", "R", "cli.R"))
source(file.path("core", "R", "figure_assembly.R"))
opts <- parse_common_args()
set.seed(opts$seed)

panel_plan <- list(
  {joined_records}
)

audit <- run_figure_analysis("{Path(module.path).name}", panel_plan, opts)
write_run_metadata(
  opts$output_dir,
  "{Path(module.path).name}_analysis",
  opts,
  list(
    computational_panels = sum(audit$status == "written"),
    documented_noncomputational_panels =
      sum(audit$status == "documented_noncomputational_panel")
  )
)
'''


def plot_script(module: Module) -> str:
    plot_records = []
    native_rows = []
    for panel in module.panels:
        if panel.package_native:
            native_rows.append((panel.panel, panel.title, panel.workflow))
            continue
        if panel.noncomputational or panel.geometry is None:
            continue
        values: dict[str, Any] = {
            "panel": panel.panel,
            "title": panel.title,
            "input": f"panel_{panel.panel}_data.tsv",
            "geometry": panel.geometry,
            **dict(panel.fields),
            "output": f"panel_{panel.panel}.pdf",
            "width": 5.5,
            "height": 4.2,
        }
        plot_records.append(r_list(values))
    if native_rows:
        native_code = (
            "package_native_panels <- tibble::tribble(\n"
            "  ~panel, ~title, ~workflow,\n"
            + ",\n".join(
                "  "
                + ", ".join(r_string(value) for value in row)
                for row in native_rows
            )
            + "\n)\n"
            "readr::write_tsv(\n"
            "  package_native_panels,\n"
            "  file.path(opts$output_dir, \"package_native_plot_manifest.tsv\")\n"
            ")\n"
        )
    else:
        native_code = (
            "package_native_panels <- tibble::tibble(\n"
            "  panel = character(), title = character(), workflow = character()\n"
            ")\n"
        )
    joined_plot_records = ",\n  ".join(plot_records)
    return f'''#!/usr/bin/env Rscript

# {Path(module.path).name} panel rendering.
# Standard panels are rendered from the exported tables below. Panels drawn
# directly by an analysis package are listed in package_native_panels.

source(file.path("core", "R", "cli.R"))
source(file.path("core", "R", "figure_assembly.R"))
opts <- parse_common_args()

plot_plan <- list(
  {joined_plot_records}
)

if (length(plot_plan)) {{
  run_figure_plots("{Path(module.path).name}", plot_plan, opts)
}}

{native_code}
write_run_metadata(
  opts$output_dir,
  "{Path(module.path).name}_plot",
  opts,
  list(
    standard_vector_panels = length(plot_plan),
    package_native_panels = nrow(package_native_panels)
  )
)
'''


def readme(module: Module) -> str:
    rows = ["| Panel | Analysis | Source workflow |", "|---|---|---|"]
    for panel in module.panels:
        rows.append(f"| {panel.panel} | {panel.title} | `{panel.workflow}` |")
    module_id = Path(module.path).name
    return f"""# {module_id}: {module.title}

## Panel-to-code map

{chr(10).join(rows)}

`01_analysis.R` records each panel's source workflow, input table and required
columns. `02_plot.R` draws the standard vector panels; panels exported directly
from an analysis package or generated experimentally are listed in the panel
map.

## Run

```bash
Rscript {module.path}/01_analysis.R \\
  --config {module.path}/config.yaml \\
  --input-dir data/processed/{module_id} \\
  --output-dir outputs/{module_id} \\
  --seed 20260730 --threads 4

Rscript {module.path}/02_plot.R \\
  --config {module.path}/config.yaml \\
  --input-dir outputs/{module_id} \\
  --output-dir outputs/{module_id} \\
  --seed 20260730 --threads 4
```

Required input columns are listed directly in `01_analysis.R`; expected files
are listed in `expected_outputs.txt`.
"""


def config(module: Module) -> str:
    return (
        f"module: {Path(module.path).name}\n"
        f'title: "{module.title}"\n'
        "seed: 20260730\n"
        "vector_format: pdf\n"
        "table_format: tsv\n"
        "heavy_models_run_in: workflows\n"
    )


def expected_outputs(module: Module) -> str:
    values = ["panel_output_manifest.tsv", "panel_plot_manifest.tsv"]
    for panel in module.panels:
        if not panel.noncomputational:
            values.append(f"panel_{panel.panel}_data.tsv")
        if panel.geometry is not None and not panel.noncomputational:
            values.append(f"panel_{panel.panel}.pdf")
    values.append("run_metadata.yaml")
    return "\n".join(dict.fromkeys(values)) + "\n"


def main() -> None:
    manifest_rows = []
    for module in MODULES:
        directory = ROOT / module.path
        directory.mkdir(parents=True, exist_ok=True)
        (directory / "01_analysis.R").write_text(
            analysis_script(module), encoding="utf-8"
        )
        (directory / "02_plot.R").write_text(plot_script(module), encoding="utf-8")
        (directory / "README.md").write_text(readme(module), encoding="utf-8")
        (directory / "config.yaml").write_text(config(module), encoding="utf-8")
        (directory / "expected_outputs.txt").write_text(
            expected_outputs(module), encoding="utf-8"
        )
        for panel in module.panels:
            panel_type = (
                "noncomputational"
                if panel.noncomputational
                else "package_native"
                if panel.package_native
                else "standard_vector"
            )
            manifest_rows.append(
                {
                    "figure": Path(module.path).name,
                    "panel": panel.panel,
                    "title": panel.title,
                    "module": module.path,
                    "analysis_script": f"{module.path}/01_analysis.R",
                    "plot_script": f"{module.path}/02_plot.R",
                    "source_workflow": panel.workflow,
                    "panel_type": panel_type,
                    "status": "implemented_v0.4",
                }
            )

    manifest_path = ROOT / "manifests" / "figure_manifest.tsv"
    with manifest_path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=(
                "figure",
                "panel",
                "title",
                "module",
                "analysis_script",
                "plot_script",
                "source_workflow",
                "panel_type",
                "status",
            ),
            delimiter="\t",
            lineterminator="\n",
        )
        writer.writeheader()
        writer.writerows(manifest_rows)


if __name__ == "__main__":
    main()
