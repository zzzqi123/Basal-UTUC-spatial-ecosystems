#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(clusterProfiler)
  library(org.Hs.eg.db)
  library(readr)
  library(dplyr)
})

source(file.path("core", "R", "cli.R"))
opts <- parse_common_args()
markers <- read_tsv(
  require_input(opts$input_dir, "findallmarkers_all_clusters.tsv.gz"),
  show_col_types = FALSE
)
hallmark <- read_tsv(
  require_input(opts$input_dir, "hallmark_gene_sets.tsv"),
  show_col_types = FALSE
)
required <- c("cluster", "gene", "avg_log2FC", "p_val_adj")
missing <- setdiff(required, names(markers))
if (length(missing)) stop("Marker table missing: ", paste(missing, collapse = ", "))
if (!all(c("pathway", "gene") %in% names(hallmark))) {
  stop("Hallmark table requires pathway and gene columns")
}

significant <- markers %>%
  filter(p_val_adj < 0.05, avg_log2FC > 0.25)
ora_results <- lapply(split(significant$gene, significant$cluster), function(genes) {
  converted <- bitr(
    unique(genes),
    fromType = "SYMBOL",
    toType = "ENTREZID",
    OrgDb = org.Hs.eg.db
  )
  if (!nrow(converted)) return(NULL)
  go <- as.data.frame(
    enrichGO(
      gene = converted$ENTREZID,
      OrgDb = org.Hs.eg.db,
      ont = "BP",
      pAdjustMethod = "BH",
      readable = TRUE
    )
  )
  kegg <- as.data.frame(
    enrichKEGG(
      gene = converted$ENTREZID,
      organism = "hsa",
      pAdjustMethod = "BH"
    )
  )
  bind_rows(
    mutate(go, collection = "GO_BP"),
    mutate(kegg, collection = "KEGG")
  )
})
ora_output <- bind_rows(ora_results, .id = "cluster")

gsea_results <- lapply(split(markers, markers$cluster), function(cluster_markers) {
  ranked <- cluster_markers %>%
    filter(is.finite(avg_log2FC), !is.na(gene)) %>%
    group_by(gene) %>%
    summarise(
      rank_statistic = avg_log2FC[which.max(abs(avg_log2FC))],
      .groups = "drop"
    )
  gene_list <- setNames(ranked$rank_statistic, ranked$gene)
  gene_list <- sort(gene_list, decreasing = TRUE)
  if (length(gene_list) < 20L) return(NULL)
  as.data.frame(
    GSEA(
      geneList = gene_list,
      TERM2GENE = hallmark[, c("pathway", "gene")],
      minGSSize = 5,
      maxGSSize = 500,
      pAdjustMethod = "BH",
      seed = TRUE,
      verbose = FALSE
    )
  )
})
gsea_output <- bind_rows(gsea_results, .id = "cluster")

dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
write_tsv(ora_output, file.path(opts$output_dir, "go_kegg_overrepresentation.tsv"))
write_tsv(gsea_output, file.path(opts$output_dir, "hallmark_gsea.tsv"))
write_run_metadata(
  opts$output_dir,
  "cluster_functional_enrichment",
  opts,
  list(
    overrepresentation = c("GO_BP", "KEGG"),
    ranked_enrichment = "Hallmark GSEA",
    p_adjustment = "BH"
  )
)
