#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(CellChat)
  library(future)
  library(readr)
  library(Seurat)
  library(yaml)
})

source(file.path("core", "R", "cli.R"))
opts <- parse_common_args()
cfg <- yaml::read_yaml(opts$config)$spatial_cellchat
set.seed(opts$seed)

object <- readRDS(require_input(opts$input_dir, "utuc_spatial_niches.rds"))
if (!inherits(object, "Seurat")) stop("Input must be a spatial Seurat object")
if (!"celltype_niche" %in% names(object[[]])) {
  stop("celltype_niche metadata is required")
}

data_input <- GetAssayData(object, assay = "SCT", layer = "data")
groups <- factor(object$celltype_niche)
meta <- data.frame(
  labels = groups,
  samples = object$orig.ident,
  row.names = colnames(object)
)
coordinates <- GetTissueCoordinates(object)
if ("cell" %in% names(coordinates)) rownames(coordinates) <- coordinates$cell
x_name <- intersect(c("imagecol", "x", "pxl_col_in_fullres", "col"), names(coordinates))[1]
y_name <- intersect(c("imagerow", "y", "pxl_row_in_fullres", "row"), names(coordinates))[1]
coordinates <- coordinates[colnames(object), c(x_name, y_name), drop = FALSE]
names(coordinates) <- c("x", "y")

image <- object@images[[1]]
ratio <- image@scale.factors$hires
if (!is.finite(ratio) || ratio <= 0) stop("Valid hires scale factor is required")
spatial_factors <- data.frame(ratio = ratio, tol = 32.5)

cellchat <- createCellChat(
  object = data_input,
  meta = meta,
  group.by = "labels",
  datatype = "spatial",
  coordinates = as.matrix(coordinates),
  spatial.factors = spatial_factors
)
cellchat@DB <- CellChatDB.human
cellchat <- subsetData(cellchat)
future::plan("multisession", workers = opts$threads)
cellchat <- identifyOverExpressedGenes(cellchat)
cellchat <- identifyOverExpressedInteractions(cellchat)
cellchat <- computeCommunProb(
  cellchat,
  type = cfg$probability_type,
  trim = cfg$trim,
  distance.use = cfg$distance_use,
  interaction.range = cfg$interaction_range_um,
  scale.distance = cfg$scale_distance,
  contact.dependent = cfg$contact_dependent,
  contact.range = cfg$contact_range_um,
  seed.use = opts$seed
)
cellchat <- filterCommunication(cellchat, min.cells = cfg$min_cells)
cellchat <- computeCommunProbPathway(cellchat)
cellchat <- aggregateNet(cellchat)
communication <- subsetCommunication(cellchat)

dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
write_tsv(communication, file.path(opts$output_dir, "spatial_cellchat_interactions.tsv.gz"))
saveRDS(cellchat, file.path(opts$output_dir, "spatial_cellchat_object.rds"))
write_run_metadata(
  opts$output_dir,
  "spatial_niche_cellchat",
  opts,
  list(
    database = cfg$database,
    interaction_range_um = cfg$interaction_range_um,
    contact_range_um = cfg$contact_range_um,
    min_cells = cfg$min_cells
  )
)
