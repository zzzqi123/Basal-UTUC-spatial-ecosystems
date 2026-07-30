#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dplyr)
  library(infercnv)
  library(Matrix)
  library(readr)
  library(scales)
  library(Seurat)
  library(yaml)
})

source(file.path("core", "R", "cli.R"))
opts <- parse_common_args()
cfg <- yaml::read_yaml(opts$config)$single_cell
set.seed(opts$seed)

object <- readRDS(require_input(opts$input_dir, "utuc_epithelial_cells.rds"))
gene_order <- require_input(opts$input_dir, "hg38_gene_order.tsv")
if (!inherits(object, "Seurat")) stop("Input must be an epithelial Seurat object")
required_metadata <- c("orig.ident", "tissue_group", "epithelial_cluster")
if (length(setdiff(required_metadata, names(object[[]])))) {
  stop("Metadata requires orig.ident, tissue_group and epithelial_cluster")
}

counts <- GetAssayData(object, assay = "RNA", layer = "counts")
annotations <- data.frame(
  cell = colnames(object),
  infercnv_group = paste(
    object$tissue_group,
    object$epithelial_cluster,
    sep = "_"
  )
)
reference_groups <- sort(unique(
  annotations$infercnv_group[object$tissue_group == "Adjacent"]
))
if (!length(reference_groups)) stop("No adjacent epithelial reference cells found")

dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
annotation_path <- file.path(opts$output_dir, "infercnv_annotations.tsv")
write_tsv(annotations, annotation_path, col_names = FALSE)

infercnv_object <- CreateInfercnvObject(
  raw_counts_matrix = counts,
  annotations_file = annotation_path,
  delim = "\t",
  gene_order_file = gene_order,
  ref_group_names = reference_groups,
  chr_exclude = c("chrY", "chrM")
)
infercnv_object <- infercnv::run(
  infercnv_object,
  cutoff = cfg$infercnv_cutoff,
  out_dir = file.path(opts$output_dir, "infercnv_run"),
  no_prelim_plot = TRUE,
  cluster_by_groups = TRUE,
  denoise = TRUE,
  HMM = FALSE,
  min_cells_per_gene = cfg$infercnv_min_cells_per_gene,
  num_threads = opts$threads,
  write_expr_matrix = TRUE
)

cnv_matrix <- infercnv_object@expr.data
scaled <- t(scale(t(as.matrix(cnv_matrix))))
scaled <- apply(scaled, 1, scales::rescale, to = c(-1, 1))
scaled <- t(scaled)
cnv_score <- colSums(scaled ^ 2, na.rm = TRUE)
high_count <- max(1L, ceiling(length(cnv_score) * cfg$cnv_high_score_fraction))
high_cells <- names(sort(cnv_score, decreasing = TRUE))[seq_len(high_count)]
reference_profile <- rowMeans(scaled[, high_cells, drop = FALSE], na.rm = TRUE)
cnv_correlation <- apply(
  scaled,
  2,
  function(profile) cor(profile, reference_profile, method = "pearson")
)

classification <- data.frame(
  cell_id = names(cnv_score),
  cnv_score = as.numeric(cnv_score),
  high_cnv_profile_correlation = cnv_correlation[names(cnv_score)],
  malignant = cnv_score > cfg$cnv_score_threshold &
    cnv_correlation[names(cnv_score)] > cfg$cnv_correlation_threshold
)
write_tsv(
  classification,
  file.path(opts$output_dir, "infercnv_malignant_cell_classification.tsv.gz")
)
saveRDS(
  infercnv_object,
  file.path(opts$output_dir, "infercnv_adjacent_epithelial_reference.rds")
)
write_run_metadata(
  opts$output_dir,
  "infercnv_adjacent_epithelial_reference",
  opts,
  list(
    cutoff = cfg$infercnv_cutoff,
    reference_groups = reference_groups,
    cnv_score_threshold = cfg$cnv_score_threshold,
    correlation_threshold = cfg$cnv_correlation_threshold,
    high_cnv_fraction = cfg$cnv_high_score_fraction
  )
)
