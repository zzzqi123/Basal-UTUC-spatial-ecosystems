#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(ClusterGVis)
  library(dplyr)
  library(Nebulosa)
  library(org.Hs.eg.db)
  library(readr)
  library(Seurat)
})

source(file.path("core", "R", "cli.R"))
opts <- parse_common_args()
object <- readRDS(require_input(opts$input_dir, "utuc_annotated_scrna.rds"))
markers <- read_tsv(
  require_input(opts$input_dir, "findallmarkers_all_clusters.tsv.gz"),
  show_col_types = FALSE
)
if (!inherits(object, "Seurat")) stop("Input must be a Seurat object")

top_markers <- markers %>%
  filter(p_val_adj < 0.05) %>%
  group_by(cluster) %>%
  slice_max(avg_log2FC, n = 10, with_ties = FALSE) %>%
  ungroup()

cluster_data <- prepareDataFromscRNA(
  object = object,
  diffData = top_markers,
  showAverage = TRUE
)
enrichment <- enrichCluster(
  object = cluster_data,
  OrgDb = org.Hs.eg.db,
  type = "BP",
  organism = "hsa",
  pvalueCutoff = 0.05,
  topn = 10,
  seed = opts$seed
)

dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
saveRDS(cluster_data, file.path(opts$output_dir, "clustergvis_marker_heatmap_data.rds"))
write_tsv(
  as.data.frame(enrichment),
  file.path(opts$output_dir, "clustergvis_cluster_enrichment.tsv")
)

marker_genes <- unique(top_markers$gene)
pdf(file.path(opts$output_dir, "clustergvis_marker_heatmap.pdf"), width = 14, height = 12)
print(visCluster(
  object = cluster_data,
  plot.type = "both",
  show_row_dend = FALSE,
  markGenes = marker_genes,
  annoTerm.data = enrichment,
  add.bar = TRUE
))
dev.off()

density_genes <- head(intersect(marker_genes, rownames(object)), 12L)
if (length(density_genes)) {
  pdf(file.path(opts$output_dir, "nebulosa_marker_density.pdf"), width = 12, height = 9)
  print(Nebulosa::plot_density(
    object,
    features = density_genes,
    reduction = "umap",
    joint = FALSE
  ))
  dev.off()
}
write_run_metadata(
  opts$output_dir,
  "single_cell_marker_visualization",
  opts,
  list(
    heatmap = "ClusterGVis",
    density = "Nebulosa",
    top_markers_per_cluster = 10
  )
)
