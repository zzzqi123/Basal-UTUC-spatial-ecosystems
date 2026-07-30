#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(Seurat)
  library(readr)
})

source(file.path("core", "R", "cli.R"))
opts <- parse_common_args()

sample_sheet <- read_tsv(
  require_input(opts$input_dir, "spatial_sample_sheet.tsv"),
  show_col_types = FALSE
)
required <- c("sample_id", "spaceranger_output", "stage")
missing <- setdiff(required, names(sample_sheet))
if (length(missing)) stop("Spatial sample sheet missing: ", paste(missing, collapse = ", "))

process_section <- function(sample_id, spaceranger_output, stage) {
  directory <- file.path(opts$input_dir, spaceranger_output)
  if (!dir.exists(directory)) stop("Space Ranger output not found: ", directory)
  object <- Load10X_Spatial(
    data.dir = directory,
    assay = "Spatial",
    slice = sample_id,
    filter.matrix = TRUE
  )
  object$sample <- sample_id
  object$stage <- stage
  object <- SCTransform(
    object,
    assay = "Spatial",
    return.only.var.genes = FALSE,
    verbose = FALSE
  )
  object <- RunPCA(object, assay = "SCT", npcs = 30, verbose = FALSE)
  object <- FindNeighbors(object, reduction = "pca", dims = 1:20, verbose = FALSE)
  object <- FindClusters(object, resolution = 0.3, random.seed = opts$seed)
  object <- RunUMAP(object, reduction = "pca", dims = 1:20, seed.use = opts$seed)
  object
}

sections <- Map(
  process_section,
  sample_sheet$sample_id,
  sample_sheet$spaceranger_output,
  sample_sheet$stage
)
names(sections) <- sample_sheet$sample_id
dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
saveRDS(sections, file.path(opts$output_dir, "visium_sections_processed.rds"))
write_run_metadata(
  opts$output_dir,
  "visium_preprocessing",
  opts,
  list(
    input = "Space Ranger filtered feature-barcode matrices",
    normalisation = "SCTransform for visualization; raw counts retained for cell2location"
  )
)
