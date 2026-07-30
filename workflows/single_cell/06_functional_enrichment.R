#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(clusterProfiler)
  library(org.Hs.eg.db)
  library(readr)
  library(dplyr)
})

source(file.path("core", "R", "cli.R"))
opts <- parse_common_args()
markers <- read_tsv(require_input(opts$input_dir, "marker_genes.tsv"), show_col_types = FALSE)
required <- c("cluster", "gene", "avg_log2FC", "p_val_adj")
missing <- setdiff(required, names(markers))
if (length(missing)) stop("Marker table missing: ", paste(missing, collapse = ", "))

significant <- markers %>%
  filter(p_val_adj < 0.05, avg_log2FC > 0.25)
results <- lapply(split(significant$gene, significant$cluster), function(genes) {
  converted <- bitr(
    unique(genes),
    fromType = "SYMBOL",
    toType = "ENTREZID",
    OrgDb = org.Hs.eg.db
  )
  if (!nrow(converted)) return(NULL)
  as.data.frame(
    enrichGO(
      gene = converted$ENTREZID,
      OrgDb = org.Hs.eg.db,
      ont = "BP",
      pAdjustMethod = "BH",
      readable = TRUE
    )
  )
})
output <- bind_rows(results, .id = "cluster")
dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
write_tsv(output, file.path(opts$output_dir, "go_bp_enrichment.tsv"))
write_run_metadata(opts$output_dir, "cluster_functional_enrichment", opts)

