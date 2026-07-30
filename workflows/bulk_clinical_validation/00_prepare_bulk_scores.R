#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dplyr)
  library(estimate)
  library(GSVA)
  library(readr)
  library(tibble)
  library(yaml)
})

source(file.path("core", "R", "cli.R"))
opts <- parse_common_args()
cfg <- yaml::read_yaml(opts$config)$bulk_clinical
set.seed(opts$seed)

expression_table <- read_tsv(
  require_input(opts$input_dir, "bulk_expression_symbols.tsv.gz"),
  show_col_types = FALSE
)
metadata <- read_tsv(
  require_input(opts$input_dir, "bulk_sample_metadata.tsv"),
  show_col_types = FALSE
)
base47 <- read_tsv(
  require_input(opts$input_dir, "base47_gene_sets.tsv"),
  show_col_types = FALSE
)
if (!"gene" %in% names(expression_table)) {
  stop("Bulk expression table requires a gene column")
}
if (!all(c("sample_id") %in% names(metadata))) {
  stop("Bulk metadata requires sample_id")
}
if (!all(c("program", "gene") %in% names(base47))) {
  stop("BASE47 table requires program and gene columns")
}

expression_table <- expression_table %>%
  group_by(gene) %>%
  summarise(across(where(is.numeric), mean, na.rm = TRUE), .groups = "drop")
expression <- as.matrix(column_to_rownames(expression_table, "gene"))
storage.mode(expression) <- "double"
common_samples <- intersect(colnames(expression), metadata$sample_id)
if (length(common_samples) < 3L) stop("Fewer than three samples are aligned")
expression <- expression[, common_samples, drop = FALSE]
metadata <- metadata[match(common_samples, metadata$sample_id), , drop = FALSE]

gene_sets <- split(base47$gene, base47$program)
if (!all(
  c(cfg$base47_basal_label, cfg$base47_luminal_label) %in% names(gene_sets)
)) {
  stop("BASE47 program labels do not match the configured Basal/Luminal labels")
}
if ("gsvaParam" %in% getNamespaceExports("GSVA")) {
  gsva_parameters <- GSVA::gsvaParam(expression, gene_sets)
  gsva_scores <- GSVA::gsva(gsva_parameters, verbose = FALSE)
} else {
  gsva_scores <- GSVA::gsva(
    expression,
    gene_sets,
    method = "gsva",
    verbose = FALSE,
    parallel.sz = opts$threads
  )
}

dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
estimate_input <- file.path(opts$output_dir, "estimate_expression_input.tsv")
estimate_filtered <- file.path(opts$output_dir, "estimate_common_genes.gct")
estimate_output <- file.path(opts$output_dir, "estimate_scores.gct")
write.table(
  data.frame(GeneSymbol = rownames(expression), expression, check.names = FALSE),
  estimate_input,
  sep = "\t",
  quote = FALSE,
  row.names = FALSE
)
estimate::filterCommonGenes(
  input.f = estimate_input,
  output.f = estimate_filtered,
  id = "GeneSymbol"
)
estimate::estimateScore(
  input.ds = estimate_filtered,
  output.ds = estimate_output,
  platform = "illumina"
)
estimate_gct <- read.delim(
  estimate_output,
  skip = 2,
  check.names = FALSE,
  stringsAsFactors = FALSE
)
estimate_matrix <- as.matrix(estimate_gct[, -(1:2), drop = FALSE])
storage.mode(estimate_matrix) <- "double"
rownames(estimate_matrix) <- estimate_gct[[1]]
estimate_scores <- as.data.frame(t(estimate_matrix)) %>%
  rownames_to_column("sample_id")

gsva_table <- as.data.frame(t(gsva_scores)) %>%
  rownames_to_column("sample_id") %>%
  mutate(
    basal_luminal_score =
      .data[[cfg$base47_basal_label]] -
      .data[[cfg$base47_luminal_label]],
    subtype = if_else(basal_luminal_score >= 0, "Basal_high", "Luminal_high")
  )
output <- metadata %>%
  left_join(gsva_table, by = "sample_id") %>%
  left_join(estimate_scores, by = "sample_id")

write_tsv(output, file.path(opts$output_dir, "bulk_estimate_base47_scores.tsv"))
write_run_metadata(
  opts$output_dir,
  "bulk_estimate_and_base47_gsva",
  opts,
  list(
    estimate = c("ImmuneScore", "StromalScore"),
    base47 = names(gene_sets),
    subtype_score = "Basal GSVA minus Luminal GSVA"
  )
)
