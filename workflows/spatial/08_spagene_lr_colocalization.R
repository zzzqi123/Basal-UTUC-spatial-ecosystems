#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dplyr)
  library(Matrix)
  library(RANN)
  library(readr)
  library(Seurat)
  library(SpaGene)
  library(yaml)
})

source(file.path("core", "R", "cli.R"))
opts <- parse_common_args()
cfg <- yaml::read_yaml(opts$config)$spatial_colocalization
set.seed(opts$seed)

object <- readRDS(require_input(opts$input_dir, "utuc_spatial_seurat.rds"))
lr_pairs <- read_tsv(
  require_input(opts$input_dir, "ligand_receptor_pairs.tsv"),
  show_col_types = FALSE
)
if (!inherits(object, "Seurat")) stop("Spatial input must be a Seurat object")
if (!all(c("pair_id", "ligand", "receptor") %in% names(lr_pairs))) {
  stop("LR table requires pair_id, ligand and receptor")
}

counts <- GetAssayData(object, assay = "Spatial", layer = "counts")
coordinates <- GetTissueCoordinates(object)
if ("cell" %in% names(coordinates)) rownames(coordinates) <- coordinates$cell
x_name <- intersect(c("imagecol", "x", "pxl_col_in_fullres", "col"), names(coordinates))[1]
y_name <- intersect(c("imagerow", "y", "pxl_row_in_fullres", "row"), names(coordinates))[1]
if (is.na(x_name) || is.na(y_name)) stop("Spatial coordinate columns not found")
coordinates <- coordinates[colnames(counts), c(x_name, y_name), drop = FALSE]
names(coordinates) <- c("x", "y")
if (nrow(coordinates) < 2L) stop("At least two spatial locations are required")

expressed <- lr_pairs$ligand %in% rownames(counts) &
  lr_pairs$receptor %in% rownames(counts)
lr_pairs <- lr_pairs[expressed, , drop = FALSE]
if (!nrow(lr_pairs)) stop("No requested ligand-receptor genes are expressed")
lr_matrix <- as.matrix(lr_pairs[, c("ligand", "receptor")])
rownames(lr_matrix) <- lr_pairs$pair_id

global_result <- SpaGene::SpaGene_LR(
  counts,
  coordinates,
  LRpair = lr_matrix,
  knn = cfg$spagene_knn
)
global_result <- as.data.frame(global_result)
global_result$pair_id <- rownames(global_result)

library_size <- Matrix::colSums(counts)
normalised <- Matrix::t(
  log1p(Matrix::t(counts) / library_size * median(library_size))
)
neighbor_query_k <- min(cfg$spagene_knn + 1L, nrow(coordinates))
neighbors <- RANN::nn2(
  as.matrix(coordinates),
  k = neighbor_query_k
)$nn.idx

local_scores <- lapply(seq_len(nrow(lr_pairs)), function(index) {
  ligand <- as.numeric(normalised[lr_pairs$ligand[index], ])
  receptor <- as.numeric(normalised[lr_pairs$receptor[index], ])
  neighbor_ligand <- vapply(seq_len(nrow(neighbors)), function(row_index) {
    ids <- setdiff(neighbors[row_index, ], row_index)
    max(ligand[head(ids, cfg$spagene_knn)], na.rm = TRUE)
  }, numeric(1))
  neighbor_receptor <- vapply(seq_len(nrow(neighbors)), function(row_index) {
    ids <- setdiff(neighbors[row_index, ], row_index)
    max(receptor[head(ids, cfg$spagene_knn)], na.rm = TRUE)
  }, numeric(1))
  score <- pmax(ligand * neighbor_receptor, receptor * neighbor_ligand)
  cap <- quantile(score, cfg$spagene_max_quantile, na.rm = TRUE)
  score[score > cap] <- cap
  data.frame(
    spot_id = colnames(counts),
    x = coordinates$x,
    y = coordinates$y,
    pair_id = lr_pairs$pair_id[index],
    ligand = lr_pairs$ligand[index],
    receptor = lr_pairs$receptor[index],
    local_lr_score = score
  )
}) |> bind_rows()

dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
write_tsv(global_result, file.path(opts$output_dir, "spagene_lr_global.tsv"))
write_tsv(local_scores, file.path(opts$output_dir, "spagene_lr_spot_scores.tsv.gz"))
write_run_metadata(
  opts$output_dir,
  "spagene_ligand_receptor_colocalization",
  opts,
  list(
    knn = cfg$spagene_knn,
    local_score = "maximum cross-neighbour ligand-receptor product",
    display_cap_quantile = cfg$spagene_max_quantile
  )
)
