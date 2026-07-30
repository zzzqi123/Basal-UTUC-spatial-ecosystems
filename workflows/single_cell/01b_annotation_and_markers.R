#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(Seurat)
  library(yaml)
})

source(file.path("core", "R", "cli.R"))
opts <- parse_common_args()
cfg <- yaml::read_yaml(opts$config)$single_cell
set.seed(opts$seed)

object <- readRDS(require_input(opts$input_dir, "utuc_scrna_processed.rds"))
if (!inherits(object, "Seurat")) stop("Input must be a Seurat object")

canonical_markers <- list(
  B_cell = c("MS4A1", "CD79A"),
  Plasma_cell = c("IGHG1", "IGHG3"),
  Cycling = c("MKI67", "CCNA2", "CCNB2"),
  Neutrophil = c("FCGR3B", "CXCR2", "CSF3R"),
  Myeloid = c("MAFB", "CSF1R", "CD163", "CD14"),
  Mast_cell = c("TPSAB1", "MS4A2"),
  pDC = c("LILRA4", "GZMB"),
  Mesenchymal = c("COL1A1", "COL1A2"),
  Endothelial = c("VWF", "PECAM1"),
  Epithelial = c("EPCAM", "KRT19"),
  T_NK = c("CD3D", "CD3E", "NKG7")
)

marker_table <- FindAllMarkers(
  object,
  assay = "RNA",
  test.use = "wilcox",
  only.pos = TRUE,
  min.pct = cfg$marker_min_percent,
  logfc.threshold = cfg$marker_log2fc,
  random.seed = opts$seed
) %>%
  filter(p_val_adj < cfg$marker_fdr) %>%
  arrange(cluster, desc(avg_log2FC))

marker_catalog <- stack(canonical_markers)
names(marker_catalog) <- c("gene", "proposed_lineage")
marker_catalog$detected <- marker_catalog$gene %in% rownames(object)

cluster_marker_support <- marker_table %>%
  inner_join(marker_catalog, by = "gene") %>%
  group_by(cluster, proposed_lineage) %>%
  summarise(
    n_supporting_markers = n_distinct(gene),
    supporting_markers = paste(sort(unique(gene)), collapse = ";"),
    .groups = "drop"
  )

dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
write_tsv(marker_table, file.path(opts$output_dir, "findallmarkers_all_clusters.tsv.gz"))
write_tsv(marker_catalog, file.path(opts$output_dir, "canonical_marker_catalog.tsv"))
write_tsv(
  cluster_marker_support,
  file.path(opts$output_dir, "cluster_canonical_marker_support.tsv")
)
write_run_metadata(
  opts$output_dir,
  "single_cell_annotation_and_markers",
  opts,
  list(
    annotation = "manual review of canonical markers",
    marker_test = "Seurat Wilcoxon",
    min_percent = cfg$marker_min_percent,
    log2fc_threshold = cfg$marker_log2fc,
    marker_fdr = cfg$marker_fdr
  )
)
