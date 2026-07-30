#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(scTenifoldKnk)
  library(Seurat)
})

source(file.path("core", "R", "cli.R"))
opts <- parse_common_args()
object <- readRDS(require_input(opts$input_dir, "utuc_tme_cells.rds"))
if (!inherits(object, "Seurat")) stop("Input must be a Seurat object")
counts <- GetAssayData(object, assay = "RNA", layer = "counts")
targets <- c("SPP1", "FAP")
missing <- setdiff(targets, rownames(counts))
if (length(missing)) stop("Perturbation targets absent: ", paste(missing, collapse = ", "))
set.seed(opts$seed)

dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
summaries <- lapply(targets, function(target) {
  result <- scTenifoldKnk(
    countMatrix = as.matrix(counts),
    gKO = target,
    qc = TRUE,
    qc_mtThreshold = 0.1,
    nNet = 10,
    nCells = min(500L, ncol(counts)),
    nComp = 3,
    scale = TRUE
  )
  saveRDS(
    result,
    file.path(opts$output_dir, paste0(tolower(target), "_tme_virtual_knockout.rds"))
  )
  data.frame(
    target = target,
    compartment = "tumor microenvironment",
    n_input_cells = ncol(counts),
    n_networks = 10,
    sampled_cells_per_network = min(500L, ncol(counts))
  )
}) %>% bind_rows()
write_tsv(summaries, file.path(opts$output_dir, "sctenifoldknk_tme_run_summary.tsv"))
write_run_metadata(
  opts$output_dir,
  "sctenifoldknk_tme_targets",
  opts,
  list(
    targets = targets,
    claim_boundary = "network perturbation hypothesis generation"
  )
)
