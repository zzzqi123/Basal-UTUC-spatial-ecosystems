#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(Matrix)
  library(readr)
  library(Seurat)
  library(spacexr)
  library(yaml)
})

source(file.path("core", "R", "cli.R"))
opts <- parse_common_args()
config <- yaml::read_yaml(opts$config)
cfg <- config$rctd
dataset_cfg <- config$external_dataset
set.seed(opts$seed)

if (is.null(dataset_cfg$id) || is.null(dataset_cfg$rctd_mode)) {
  stop("Config requires external_dataset.id and external_dataset.rctd_mode")
}
if (!dataset_cfg$rctd_mode %in% c("full", "doublet")) {
  stop("RCTD mode must be full or doublet")
}

spatial <- readRDS(require_input(opts$input_dir, dataset_cfg$spatial_object))
reference <- readRDS(require_input(opts$input_dir, dataset_cfg$reference_object))
if (!inherits(spatial, "Seurat") || !inherits(reference, "Seurat")) {
  stop("Both external spatial and reference inputs must be Seurat objects")
}

get_counts <- function(object, assay) {
  GetAssayData(object, assay = assay, layer = "counts")
}

reference_counts <- get_counts(reference, dataset_cfg$reference_assay)
labels <- reference[[dataset_cfg$reference_label, drop = TRUE]]
names(labels) <- colnames(reference)
keep_reference <- !is.na(labels) & Matrix::colSums(reference_counts) > 0
reference_counts <- reference_counts[, keep_reference, drop = FALSE]
labels <- droplevels(factor(labels[keep_reference]))
names(labels) <- colnames(reference_counts)

spatial_counts <- get_counts(spatial, dataset_cfg$spatial_assay)
keep_spots <- Matrix::colSums(spatial_counts) >= cfg$min_spot_umi
spatial <- subset(spatial, cells = colnames(spatial_counts)[keep_spots])
spatial_counts <- get_counts(spatial, dataset_cfg$spatial_assay)

coordinates <- GetTissueCoordinates(spatial)
if ("cell" %in% names(coordinates)) rownames(coordinates) <- coordinates$cell
x_name <- intersect(c("x", "imagecol", "pxl_col_in_fullres", "col"), names(coordinates))[1]
y_name <- intersect(c("y", "imagerow", "pxl_row_in_fullres", "row"), names(coordinates))[1]
if (is.na(x_name) || is.na(y_name)) stop("Spatial coordinate columns not found")
coordinates <- coordinates[colnames(spatial_counts), c(x_name, y_name), drop = FALSE]
names(coordinates) <- c("x", "y")

common_genes <- intersect(rownames(reference_counts), rownames(spatial_counts))
reference_counts <- reference_counts[common_genes, , drop = FALSE]
spatial_counts <- spatial_counts[common_genes, , drop = FALSE]
keep_genes <- Matrix::rowSums(reference_counts) > 0 &
  Matrix::rowSums(spatial_counts) > 0
reference_counts <- as(reference_counts[keep_genes, , drop = FALSE], "dgCMatrix")
spatial_counts <- as(spatial_counts[keep_genes, , drop = FALSE], "dgCMatrix")
reference_counts@x <- round(reference_counts@x)
spatial_counts@x <- round(spatial_counts@x)
reference_counts <- Matrix::drop0(reference_counts)
spatial_counts <- Matrix::drop0(spatial_counts)

reference_object <- Reference(
  counts = reference_counts,
  cell_types = labels,
  nUMI = Matrix::colSums(reference_counts)
)
puck <- SpatialRNA(
  coords = coordinates,
  counts = spatial_counts,
  nUMI = Matrix::colSums(spatial_counts)
)
rctd <- create.RCTD(
  spatialRNA = puck,
  reference = reference_object,
  max_cores = opts$threads
)
rctd <- run.RCTD(rctd, doublet_mode = dataset_cfg$rctd_mode)

weights <- as.matrix(rctd@results$weights)
if (all(colnames(spatial) %in% rownames(weights))) {
  weights <- weights[colnames(spatial), , drop = FALSE]
} else if (all(colnames(spatial) %in% colnames(weights))) {
  weights <- t(weights[, colnames(spatial), drop = FALSE])
} else {
  stop("RCTD weights cannot be aligned to spatial spots")
}
if (isTRUE(cfg$normalize_weights)) {
  weights <- sweep(weights, 1, rowSums(weights), "/")
  weights[!is.finite(weights)] <- 0
}

weight_table <- as.data.frame(weights)
weight_table$spot_id <- rownames(weight_table)
weight_table$x <- coordinates[weight_table$spot_id, "x"]
weight_table$y <- coordinates[weight_table$spot_id, "y"]
qc <- data.frame(
  dataset = dataset_cfg$id,
  retained_spots = ncol(spatial_counts),
  reference_cells = ncol(reference_counts),
  common_genes = nrow(reference_counts),
  rctd_mode = dataset_cfg$rctd_mode,
  min_spot_umi = cfg$min_spot_umi
)

dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
write_tsv(weight_table, file.path(opts$output_dir, "rctd_celltype_proportions.tsv.gz"))
write_tsv(qc, file.path(opts$output_dir, "rctd_qc.tsv"))
if (!is.null(rctd@results$results_df)) {
  results_df <- as.data.frame(rctd@results$results_df)
  results_df$spot_id <- rownames(results_df)
  write_tsv(results_df, file.path(opts$output_dir, "rctd_spot_assignments.tsv.gz"))
}
saveRDS(rctd, file.path(opts$output_dir, "rctd_object.rds"))
write_run_metadata(
  opts$output_dir,
  "external_spatial_rctd",
  opts,
  as.list(qc[1, ])
)
