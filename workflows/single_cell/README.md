# Single-cell workflows

The public branch follows the current manuscript Methods rather than copying
private exploratory notebooks.

## Processing, annotation and subclustering

- `01_process_scrna.R`: 300-6000 detected genes, mitochondrial RNA below 30%,
  hemoglobin RNA below 3%, LogNormalize at 10,000, 2,000 variable genes, 20
  PCs, Harmony by `orig.ident`, SNN clustering, UMAP and t-SNE.
- `01b_annotation_and_markers.R`: canonical-marker evidence and
  `FindAllMarkers` tables for curator-reviewed labels.
- `01c_lineage_subclustering.R`: configurable repetition of the same
  Seurat/Harmony workflow within epithelial, myeloid, neutrophil, lymphoid,
  mesenchymal or endothelial compartments. The external BLCA single-cell
  cohort uses the same interface.
- `08_marker_visualization.R`: ClusterGVis marker heatmaps and Nebulosa
  density maps.
- `09_roe_composition.R`: descriptive pooled observed/expected ratios and a
  separate sample-level negative-binomial model with a cell-count offset.

Example lineage config: `../../config/subclustering.example.yaml`.

## Malignancy and state transitions

- `02a_infercnv_adjacent_epithelial_reference.R`: manuscript-primary inferCNV
  analysis using adjacent epithelial cells as reference, followed by the
  stated CNV-score and correlation thresholds.
- `02_infercnv_non_epi_reference.R`: clearly labeled sensitivity analysis
  using immune, stromal and endothelial reference cells.
- `02b_infercnv_reference_robustness.R`: matched-cell and common-gene
  comparison of the two reference strategies, including within-sample CNV
  burden ranks, malignant-cell overlap, re-clustered marker concordance and
  Cancer_c0/Cancer_c3 Hallmark NES concordance for Supplementary Fig. S13.
- `03_trajectory_analysis.R`: primary Monocle2 analysis using expression
  filters, 1,000 q-ranked ordering genes, DDRTree and `orderCells`.
- `03b_monocle3_robustness.R`: the local final implementation,
  `scop::RunMonocle3(group.by = "celltype_byhand")`, retained as a parallel
  robustness analysis.
- `04_cytotrace2.R`: CytoTRACE2 developmental-potential scoring.

## Regulatory and functional programs

- `05_pyscenic.sh`: pySCENIC GRNBoost, motif-context pruning and AUCell stages.
- `06_functional_enrichment.R`: GO-BP and KEGG over-representation plus
  Hallmark GSEA from a two-column `pathway/gene` table.
- `07_pathway_activity.R`: AUCell and PROGENy activity.
- `10_spp1_virtual_knockout.R`: the final scTenifoldKnk analysis restricted to
  `Cancer_c0`-`Cancer_c4` malignant epithelial cells. It constructs the locked
  1,000-gene network, runs the SPP1-only perturbation with
  `nNet=5`, `nCells=1000`, `nComp=5`, `td_K=3`, `ma_nDim=2`, and exports the
  DR-gene and GO/KEGG tables used for Fig. 8B. Whole-TME or FAP knockouts are
  not part of the final analysis.

The virtual-knockout output describes network-level perturbation associations.
Its Z-score sign is not interpreted as pathway up/down-regulation, and the
analysis does not establish macrophage-to-CAF causality.

Run the finalized workflow with the manuscript-level parameter file:

```bash
Rscript workflows/single_cell/10_spp1_virtual_knockout.R \
  --config config/parameters.yaml \
  --input-dir data/processed \
  --output-dir outputs/Fig08_spp1_virtual_knockout \
  --seed 20260730 --threads 8
```

The current Methods do not specify DoubletFinder, PAGA, Slingshot or scVelo as
final analyses. They are therefore recorded as exploratory in
`../../manifests/manuscript_method_audit.tsv` and are not silently inserted
into the primary public pipeline.

Large Seurat, loom and count objects remain local inputs and are excluded from
Git.
