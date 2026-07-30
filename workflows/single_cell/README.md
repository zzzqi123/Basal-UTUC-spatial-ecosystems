# Single-cell workflow

- `01_process_scrna.R`: QC, LogNormalize, variable features, PCA, Harmony,
  neighbours, clustering, UMAP and t-SNE.
- `02_infercnv_non_epi_reference.R`: within-sample immune, stromal and
  endothelial reference for inferCNV.
- `03_trajectory_analysis.R`: Monocle3 malignant epithelial pseudotime.
- `04_cytotrace2.R`: CytoTRACE2 developmental-potential scores.
- `05_pyscenic.sh`: pySCENIC GRN, context pruning and AUCell stages.
- `06_functional_enrichment.R`: marker-based GO enrichment.
- `07_pathway_activity.R`: AUCell and PROGENy pathway activity.

Large Seurat objects are local inputs and are intentionally excluded from Git.
