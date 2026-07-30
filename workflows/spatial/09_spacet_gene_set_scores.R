#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(readr)
  library(Seurat)
  library(SpaCET)
})

source(file.path("core", "R", "cli.R"))
opts <- parse_common_args()
object <- readRDS(require_input(opts$input_dir, "utuc_spatial_seurat.rds"))
custom_sets <- readRDS(require_input(opts$input_dir, "spatial_gene_sets.rds"))
if (!inherits(object, "Seurat")) stop("Spatial input must be a Seurat object")
if (!is.list(custom_sets)) stop("spatial_gene_sets.rds must contain a named list")

counts <- GetAssayData(object, assay = "Spatial", layer = "counts")
coordinates <- GetTissueCoordinates(object)
if ("cell" %in% names(coordinates)) rownames(coordinates) <- coordinates$cell
x_name <- intersect(c("imagecol", "x", "pxl_col_in_fullres", "col"), names(coordinates))[1]
y_name <- intersect(c("imagerow", "y", "pxl_row_in_fullres", "row"), names(coordinates))[1]
if (is.na(x_name) || is.na(y_name)) stop("Spatial coordinate columns not found")
coordinates <- coordinates[colnames(counts), c(x_name, y_name), drop = FALSE]
names(coordinates) <- c("x", "y")

spacet <- create.SpaCET.object(
  counts,
  coordinates,
  platform = "Visium"
)
spacet <- SpaCET.quality.control(spacet)
spacet <- SpaCET.GeneSetScore(spacet, GeneSets = "Hallmark")
spacet <- SpaCET.GeneSetScore(spacet, GeneSets = "CancerCellState")
spacet <- SpaCET.GeneSetScore(spacet, GeneSets = "TLS")
spacet <- SpaCET.GeneSetScore(spacet, GeneSets = custom_sets)

scores <- as.data.frame(t(spacet@results[["GeneSetScore"]]))
scores$spot_id <- rownames(scores)
scores$x <- coordinates[rownames(scores), "x"]
scores$y <- coordinates[rownames(scores), "y"]

dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
write_tsv(scores, file.path(opts$output_dir, "spacet_spot_gene_set_scores.tsv.gz"))
saveRDS(spacet, file.path(opts$output_dir, "spacet_gene_set_score_object.rds"))
write_run_metadata(
  opts$output_dir,
  "spacet_spatial_gene_set_activity",
  opts,
  list(collections = c("Hallmark", "CancerCellState", "TLS", names(custom_sets)))
)
