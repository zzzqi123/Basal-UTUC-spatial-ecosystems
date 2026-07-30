#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(FNN)
  library(readr)
  library(Seurat)
  library(yaml)
})

source(file.path("core", "R", "cli.R"))
source(file.path("core", "R", "analysis_helpers.R"))
opts <- parse_common_args()
config <- yaml::read_yaml(opts$config)
dataset_cfg <- config$external_dataset
set.seed(opts$seed)

object <- readRDS(require_input(opts$input_dir, dataset_cfg$spatial_object))
weights <- read_tsv(
  require_input(opts$input_dir, "rctd_celltype_proportions.tsv.gz"),
  show_col_types = FALSE
)
if (!inherits(object, "Seurat")) stop("Input must be a Seurat object")

required <- c(
  "spot_id",
  dataset_cfg$spp1_tam_column,
  dataset_cfg$fap_mycaf_column
)
if (length(setdiff(required, names(weights)))) {
  stop("RCTD table is missing SPP1+ TAM or FAP+ myCAF columns")
}
weights <- as.data.frame(weights)
rownames(weights) <- weights$spot_id

coordinates <- GetTissueCoordinates(object)
if ("cell" %in% names(coordinates)) rownames(coordinates) <- coordinates$cell
x_name <- intersect(c("imagecol", "x", "pxl_col_in_fullres", "col"), names(coordinates))[1]
y_name <- intersect(c("imagerow", "y", "pxl_row_in_fullres", "row"), names(coordinates))[1]
common <- intersect(rownames(coordinates), rownames(weights))
if (length(common) < 2L) stop("At least two RCTD-aligned locations are required")
coordinates <- coordinates[common, c(x_name, y_name), drop = FALSE]
names(coordinates) <- c("x", "y")
weights <- weights[common, , drop = FALSE]

first <- weights[[dataset_cfg$spp1_tam_column]]
second <- weights[[dataset_cfg$fap_mycaf_column]]
same_bin <- sqrt(pmax(first, 0) * pmax(second, 0))
k <- min(dataset_cfg$neighborhood_k, nrow(coordinates) - 1L)
neighbors <- FNN::get.knn(as.matrix(coordinates), k = k)$nn.index
first_neighbor <- rowMeans(matrix(first[neighbors], nrow = nrow(neighbors)))
second_neighbor <- rowMeans(matrix(second[neighbors], nrow = nrow(neighbors)))
neighbor_score <- sqrt(
  pmax(first_neighbor, 0) * pmax(second_neighbor, 0)
)

result <- data.frame(
  spot_id = common,
  x = coordinates$x,
  y = coordinates$y,
  spp1_tam_proportion = first,
  fap_mycaf_proportion = second,
  same_bin_geometric_mean = same_bin,
  neighborhood_geometric_mean = neighbor_score,
  neighborhood_k = k
)

dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
write_tsv(result, file.path(opts$output_dir, "visiumhd_tam_mycaf_colocalization.tsv.gz"))
write_run_metadata(
  opts$output_dir,
  "visiumhd_rctd_tam_mycaf_colocalization",
  opts,
  list(
    rctd_mode = dataset_cfg$rctd_mode,
    neighborhood_k = k,
    score = "geometric mean of non-negative RCTD proportions"
  )
)
