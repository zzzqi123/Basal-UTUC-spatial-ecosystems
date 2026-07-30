#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(CytoTRACE2)
  library(Seurat)
  library(readr)
})

source(file.path("core", "R", "cli.R"))
opts <- parse_common_args()
object <- readRDS(require_input(opts$input_dir, "utuc_malignant_epithelial.rds"))
if (!inherits(object, "Seurat")) stop("Input must be a Seurat object")

counts <- GetAssayData(object, assay = "RNA", layer = "counts")
if (nrow(counts) < 1000 || ncol(counts) < 50) {
  stop("CytoTRACE2 input is unexpectedly small")
}
set.seed(opts$seed)

# The official Seurat interface adds potency predictions to object metadata.
prediction <- cytotrace2(
  object,
  species = "human",
  is_seurat = TRUE,
  slot_type = "counts",
  batch_size = 10000,
  smooth_batch_size = 1000,
  parallelize_models = TRUE,
  parallelize_smoothing = TRUE,
  ncores = opts$threads,
  seed = opts$seed
)
score_column <- intersect(
  c("CytoTRACE2_Score", "CytoTRACE2_score", "score"),
  names(prediction[[]])
)
if (!length(score_column)) stop("CytoTRACE2 score column was not returned")

output <- data.frame(
  cell_id = colnames(prediction),
  sample = prediction$orig.ident,
  cell_state = prediction$second_celltype_byhand,
  cytotrace2_score = prediction[[score_column[[1]]]],
  stringsAsFactors = FALSE
)
dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
write_tsv(output, file.path(opts$output_dir, "cytotrace2_cell_scores.tsv"))
write_run_metadata(
  opts$output_dir,
  "malignant_epithelial_cytotrace2",
  opts,
  list(
    species = "human",
    unit = "cell",
    batch_size = 10000,
    smooth_batch_size = 1000
  )
)
