#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(scop)
  library(Seurat)
  library(yaml)
})

source(file.path("core", "R", "cli.R"))
opts <- parse_common_args()
cfg <- yaml::read_yaml(opts$config)$single_cell
set.seed(opts$seed)
options(scop_env_init = TRUE)
object <- readRDS(require_input(opts$input_dir, "utuc_malignant_epithelial.rds"))
if (!inherits(object, "Seurat")) stop("Input must be a Seurat object")
if (!"celltype_byhand" %in% names(object[[]])) {
  if (!"second_celltype_byhand" %in% names(object[[]])) {
    stop("Metadata requires celltype_byhand or second_celltype_byhand")
  }
  object$celltype_byhand <- object$second_celltype_byhand
}
object$celltype_byhand <- factor(object$celltype_byhand)

object <- scop::RunMonocle3(
  object,
  group.by = "celltype_byhand"
)

dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
saveRDS(object, file.path(opts$output_dir, "scop_monocle3_malignant_object.rds"))

metadata <- object[[]]
pseudotime_columns <- grep(
  "pseudotime|pseudo_time",
  names(metadata),
  value = TRUE,
  ignore.case = TRUE
)
if (length(pseudotime_columns)) {
  trajectory <- data.frame(
    cell_id = rownames(metadata),
    cell_state = metadata$celltype_byhand,
    metadata[, pseudotime_columns, drop = FALSE],
    check.names = FALSE
  )
  write_tsv(
    trajectory,
    file.path(opts$output_dir, "scop_monocle3_pseudotime.tsv")
  )
}

reduction_names <- names(object@reductions)
embedding_manifest <- lapply(reduction_names, function(reduction_name) {
  embedding <- Embeddings(object, reduction = reduction_name)
  data.frame(
    cell_id = rownames(embedding),
    reduction = reduction_name,
    embedding,
    check.names = FALSE
  )
})
if (length(embedding_manifest)) {
  write_tsv(
    bind_rows(embedding_manifest),
    file.path(opts$output_dir, "scop_monocle3_embeddings.tsv.gz")
  )
}
write_run_metadata(
  opts$output_dir,
  "monocle3_trajectory_robustness",
  opts,
  list(
    implementation = "scop::RunMonocle3",
    group_by = "celltype_byhand",
    dimensions_recorded_in_global_config = cfg$monocle3_dimensions,
    exported_pseudotime_columns = pseudotime_columns,
    exported_reductions = reduction_names
  )
)
