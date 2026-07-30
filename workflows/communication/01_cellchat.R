#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(CellChat)
  library(Seurat)
})

source(file.path("core", "R", "cli.R"))
opts <- parse_common_args()
object <- readRDS(require_input(opts$input_dir, "utuc_scrna_annotated.rds"))
if (!inherits(object, "Seurat")) stop("Input must be a Seurat object")
if (!"second_celltype_byhand" %in% names(object[[]])) {
  stop("Missing cell-state annotation: second_celltype_byhand")
}

expression <- GetAssayData(object, assay = "RNA", layer = "data")
metadata <- object[[]]
cellchat <- createCellChat(
  object = expression,
  meta = metadata,
  group.by = "second_celltype_byhand"
)
cellchat@DB <- CellChatDB.human
cellchat <- subsetData(cellchat)
cellchat <- identifyOverExpressedGenes(cellchat)
cellchat <- identifyOverExpressedInteractions(cellchat)
cellchat <- computeCommunProb(cellchat)
cellchat <- filterCommunication(cellchat, min.cells = 10)
cellchat <- computeCommunProbPathway(cellchat)
cellchat <- aggregateNet(cellchat)

dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
saveRDS(cellchat, file.path(opts$output_dir, "cellchat_global.rds"))
write.csv(
  subsetCommunication(cellchat),
  file.path(opts$output_dir, "cellchat_interactions.csv"),
  row.names = FALSE
)
write_run_metadata(
  opts$output_dir,
  "cellchat_global",
  opts,
  list(database = "CellChatDB.human", min_cells = 10)
)

