#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(Seurat)
  library(spacexr)
})

source(file.path("core", "R", "cli.R"))
opts <- parse_common_args()
spatial <- readRDS(require_input(opts$input_dir, "external_blca_visium.rds"))
reference <- readRDS(require_input(opts$input_dir, "external_blca_reference.rds"))
if (!inherits(spatial, "Seurat") || !inherits(reference, "Seurat")) {
  stop("Both external spatial and reference inputs must be Seurat objects")
}

coordinates <- GetTissueCoordinates(spatial)
counts <- GetAssayData(spatial, assay = "Spatial", layer = "counts")
reference_counts <- GetAssayData(reference, assay = "RNA", layer = "counts")
cell_types <- factor(reference$second_celltype_byhand)
names(cell_types) <- colnames(reference_counts)
umi <- Matrix::colSums(reference_counts)

puck <- SpatialRNA(
  coords = coordinates[colnames(counts), c("x", "y")],
  counts = counts,
  nUMI = Matrix::colSums(counts)
)
reference_object <- Reference(reference_counts, cell_types, umi)
rctd <- create.RCTD(
  puck,
  reference_object,
  max_cores = opts$threads
)
rctd <- run.RCTD(rctd, doublet_mode = "full")
weights <- as.data.frame(rctd@results$weights)
weights <- weights / rowSums(weights)
weights$spot_id <- rownames(weights)

dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
write.table(
  weights,
  file.path(opts$output_dir, "external_blca_rctd_proportions.tsv"),
  sep = "\t",
  quote = FALSE,
  row.names = FALSE
)
write_run_metadata(
  opts$output_dir,
  "external_blca_rctd",
  opts,
  list(mode = "full", output = "row-normalised cell-state proportions")
)
