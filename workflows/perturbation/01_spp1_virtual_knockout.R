#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(Seurat)
  library(scTenifoldKnk)
})

source(file.path("core", "R", "cli.R"))
opts <- parse_common_args()
object <- readRDS(require_input(opts$input_dir, "utuc_malignant_epithelial.rds"))
if (!inherits(object, "Seurat")) stop("Input must be a Seurat object")

counts <- GetAssayData(object, assay = "RNA", layer = "counts")
if (!"SPP1" %in% rownames(counts)) stop("SPP1 not present in malignant epithelial counts")
set.seed(opts$seed)

result <- scTenifoldKnk(
  countMatrix = as.matrix(counts),
  gKO = "SPP1",
  qc = TRUE,
  qc_mtThreshold = 0.1,
  nNet = 10,
  nCells = min(500, ncol(counts)),
  nComp = 3,
  scale = TRUE
)

dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
saveRDS(result, file.path(opts$output_dir, "utuc_epithelial_spp1_virtual_knockout.rds"))
write_run_metadata(
  opts$output_dir,
  "epithelial_spp1_virtual_knockout",
  opts,
  list(
    target = "SPP1",
    compartment = "malignant epithelial",
    claim_boundary = "epithelial-intrinsic perturbation only"
  )
)

