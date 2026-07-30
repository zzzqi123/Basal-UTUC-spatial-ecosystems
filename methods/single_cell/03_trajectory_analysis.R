#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(Seurat)
  library(monocle3)
  library(readr)
})

source(file.path("functions", "R", "cli.R"))
opts <- parse_common_args()
object <- readRDS(require_input(opts$input_dir, "utuc_malignant_epithelial.rds"))
if (!inherits(object, "Seurat")) stop("Input must be a Seurat object")

counts <- GetAssayData(object, assay = "RNA", layer = "counts")
cell_metadata <- object[[]]
gene_metadata <- data.frame(
  gene_short_name = rownames(counts),
  row.names = rownames(counts)
)
cds <- new_cell_data_set(
  counts,
  cell_metadata = cell_metadata,
  gene_metadata = gene_metadata
)
cds <- preprocess_cds(cds, num_dim = 20, method = "PCA")
cds <- reduce_dimension(cds, reduction_method = "UMAP")
cds <- cluster_cells(cds, reduction_method = "UMAP")
cds <- learn_graph(cds)

root_candidates <- colnames(cds)[
  colData(cds)$second_celltype_byhand == "Cancer_c0"
]
if (!length(root_candidates)) stop("Cancer_c0 root cells are absent")
cds <- order_cells(cds, root_cells = root_candidates)

trajectory <- data.frame(
  cell_id = colnames(cds),
  cell_state = colData(cds)$second_celltype_byhand,
  pseudotime = pseudotime(cds)
)
dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
write_tsv(trajectory, file.path(opts$output_dir, "monocle3_pseudotime.tsv"))
saveRDS(cds, file.path(opts$output_dir, "monocle3_malignant_cds.rds"))
write_run_metadata(
  opts$output_dir,
  "monocle3_malignant_trajectory",
  opts,
  list(root_state = "Cancer_c0", reduction = "UMAP", dimensions = 20)
)

