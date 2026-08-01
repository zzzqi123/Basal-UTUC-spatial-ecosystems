#!/usr/bin/env Rscript

# Prepare the single-cell reference and bulk mixture matrices used by the
# CIBERSORTx web workflow. CIBERSORTx itself remains an external service and
# no credentials, executable or third-party source are stored here.

suppressPackageStartupMessages({
  library(Matrix)
  library(readr)
  library(Seurat)
  library(yaml)
})

source(file.path("core", "R", "cli.R"))
opts <- parse_common_args()
cfg <- yaml::read_yaml(opts$config)$cibersortx
set.seed(opts$seed)

required <- c(
  "annotation_column", "reference_assay", "max_cells_per_state",
  "excluded_reference_labels", "bulk_gene_column", "expected_bulk_samples",
  "bulk_input_scale"
)
missing_cfg <- setdiff(required, names(cfg))
if (length(missing_cfg)) {
  stop("Missing CIBERSORTx parameters: ", paste(missing_cfg, collapse = ", "))
}

reference_path <- require_input(opts$input_dir, "utuc_annotated_scrna.rds")
bulk_path <- require_input(opts$input_dir, "japan_utuc_bulk_expression.tsv.gz")
object <- readRDS(reference_path)
if (!inherits(object, "Seurat")) stop("Single-cell reference must be a Seurat object")
if (!cfg$reference_assay %in% Assays(object)) stop("Reference assay is absent")
metadata <- object[[]]
if (!cfg$annotation_column %in% names(metadata)) {
  stop("Reference annotation is absent: ", cfg$annotation_column)
}

labels <- as.character(metadata[[cfg$annotation_column]])
names(labels) <- rownames(metadata)
keep <- !is.na(labels) & nzchar(labels) &
  !labels %in% unlist(cfg$excluded_reference_labels)
labels <- labels[keep]
if (!length(labels)) stop("No eligible annotated reference cells remain")

# Reproduce the final reference export: at most 300 cells per fine-grained
# manually annotated state. Column names intentionally carry repeated state
# labels because CIBERSORTx treats them as single-cell phenotypes.
selected_cells <- unlist(lapply(split(names(labels), labels), function(cells) {
  if (length(cells) <= cfg$max_cells_per_state) cells else {
    sample(cells, cfg$max_cells_per_state)
  }
}), use.names = FALSE)
selected_labels <- labels[selected_cells]
counts <- GetAssayData(
  object,
  assay = cfg$reference_assay,
  layer = "counts"
)[, selected_cells, drop = FALSE]
counts <- counts[Matrix::rowSums(counts) > 0, , drop = FALSE]
values <- if (inherits(counts, "sparseMatrix")) counts@x else as.numeric(counts)
if (any(values < 0) || any(abs(values - round(values)) > 1e-8)) {
  stop("The single-cell reference must contain non-negative raw counts")
}

bulk <- read_tsv(bulk_path, show_col_types = FALSE, name_repair = "minimal")
if (!cfg$bulk_gene_column %in% names(bulk)) {
  stop("Bulk matrix lacks gene column: ", cfg$bulk_gene_column)
}
bulk_genes <- as.character(bulk[[cfg$bulk_gene_column]])
bulk_values <- bulk[, setdiff(names(bulk), cfg$bulk_gene_column), drop = FALSE]
if (ncol(bulk_values) != cfg$expected_bulk_samples) {
  stop(
    "Expected ", cfg$expected_bulk_samples, " bulk samples; found ",
    ncol(bulk_values)
  )
}
bulk_matrix <- as.matrix(bulk_values)
storage.mode(bulk_matrix) <- "numeric"
if (any(!is.finite(bulk_matrix)) || any(bulk_matrix < 0)) {
  stop("Bulk expression values must be finite and non-negative")
}
if (anyNA(bulk_genes) || any(!nzchar(bulk_genes))) {
  stop("Bulk gene identifiers contain missing values")
}

# Match the local final preparation: if several rows map to one symbol, keep
# the row with the largest mean expression across the bulk cohort.
row_priority <- rowMeans(bulk_matrix)
order_index <- order(row_priority, decreasing = TRUE)
keep_unique <- !duplicated(bulk_genes[order_index])
order_index <- order_index[keep_unique]
bulk_genes <- bulk_genes[order_index]
bulk_matrix <- bulk_matrix[order_index, , drop = FALSE]
rownames(bulk_matrix) <- bulk_genes

dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
reference_output <- file.path(opts$output_dir, "CIBERSORTx_scRNA_reference.txt")
connection <- file(reference_output, open = "wt")
writeLines(paste(c("GeneSymbol", unname(selected_labels)), collapse = "\t"), connection)
chunk_size <- 500L
for (first_row in seq.int(1L, nrow(counts), by = chunk_size)) {
  last_row <- min(nrow(counts), first_row + chunk_size - 1L)
  block <- as.matrix(counts[first_row:last_row, , drop = FALSE])
  block <- data.frame(GeneSymbol = rownames(block), block, check.names = FALSE)
  write.table(
    block,
    connection,
    sep = "\t",
    quote = FALSE,
    row.names = FALSE,
    col.names = FALSE
  )
}
close(connection)
bulk_table <- data.frame(
  GeneSymbol = rownames(bulk_matrix),
  bulk_matrix,
  check.names = FALSE
)
write.table(
  bulk_table,
  file.path(opts$output_dir, "CIBERSORTx_bulk_mixture.txt"),
  sep = "\t", quote = FALSE, row.names = FALSE, col.names = TRUE
)

reference_summary <- data.frame(
  cell_state = names(table(selected_labels)),
  selected_cells = as.integer(table(selected_labels)),
  stringsAsFactors = FALSE
)
write_tsv(
  reference_summary,
  file.path(opts$output_dir, "cibersortx_reference_cell_counts.tsv")
)
write_tsv(
  data.frame(
    reference_genes = nrow(counts),
    reference_cells = ncol(counts),
    reference_states = length(unique(selected_labels)),
    bulk_genes = nrow(bulk_matrix),
    bulk_samples = ncol(bulk_matrix),
    shared_genes = length(intersect(rownames(counts), rownames(bulk_matrix))),
    bulk_input_scale = cfg$bulk_input_scale
  ),
  file.path(opts$output_dir, "cibersortx_input_qc.tsv")
)
write_run_metadata(
  opts$output_dir,
  "single_cell_reference_to_bulk_cibersortx_inputs",
  opts,
  list(
    annotation = cfg$annotation_column,
    max_cells_per_state = cfg$max_cells_per_state,
    expected_bulk_samples = cfg$expected_bulk_samples,
    execution = "CIBERSORTx web service; default fraction-estimation parameters"
  )
)
