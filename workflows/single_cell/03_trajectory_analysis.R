#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(Biobase)
  library(monocle)
  library(readr)
  library(Seurat)
  library(yaml)
})

source(file.path("core", "R", "cli.R"))
opts <- parse_common_args()
cfg <- yaml::read_yaml(opts$config)$single_cell
set.seed(opts$seed)

object <- readRDS(require_input(opts$input_dir, "utuc_malignant_epithelial.rds"))
if (!inherits(object, "Seurat")) stop("Input must be a Seurat object")
counts <- GetAssayData(object, assay = "RNA", layer = "counts")
metadata <- object[[]]
metadata$cell_id <- rownames(metadata)
gene_metadata <- data.frame(
  gene_short_name = rownames(counts),
  row.names = rownames(counts)
)

cds <- newCellDataSet(
  as(counts, "sparseMatrix"),
  phenoData = new("AnnotatedDataFrame", data = metadata),
  featureData = new("AnnotatedDataFrame", data = gene_metadata),
  lowerDetectionLimit = 0.5,
  expressionFamily = negbinomial.size()
)
cds <- estimateSizeFactors(cds)
cds <- estimateDispersions(cds)
cds <- detectGenes(cds, min_expr = cfg$monocle2_min_mean_expression)
expressed <- row.names(subset(
  fData(cds),
  mean_expression > cfg$monocle2_min_mean_expression &
    num_cells_expressed >= cfg$monocle2_min_cells
))
if (!length(expressed)) stop("No genes pass Monocle2 expression filters")

differential <- differentialGeneTest(
  cds[expressed, ],
  fullModelFormulaStr = "~second_celltype_byhand",
  cores = opts$threads
)
ordering_genes <- rownames(
  head(
    differential[order(differential$qval), , drop = FALSE],
    cfg$monocle2_top_ordering_genes
  )
)
cds <- setOrderingFilter(cds, ordering_genes)
cds <- reduceDimension(
  cds,
  max_components = 2,
  reduction_method = "DDRTree",
  norm_method = "log",
  pseudo_expr = 1,
  verbose = TRUE
)
cds <- orderCells(cds)

root_states <- names(sort(
  table(pData(cds)$State[pData(cds)$second_celltype_byhand == "Cancer_c0"]),
  decreasing = TRUE
))
if (!length(root_states)) stop("Cancer_c0 root cells are absent")
cds <- orderCells(cds, root_state = as.numeric(root_states[[1]]))

trajectory <- data.frame(
  cell_id = rownames(pData(cds)),
  cell_state = pData(cds)$second_celltype_byhand,
  monocle2_state = pData(cds)$State,
  pseudotime = pData(cds)$Pseudotime
)
dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
write_tsv(trajectory, file.path(opts$output_dir, "monocle2_pseudotime.tsv"))
write_tsv(
  data.frame(gene = ordering_genes),
  file.path(opts$output_dir, "monocle2_ordering_genes.tsv")
)
saveRDS(cds, file.path(opts$output_dir, "monocle2_malignant_cds.rds"))
write_run_metadata(
  opts$output_dir,
  "monocle2_malignant_trajectory",
  opts,
  list(
    reduction = cfg$monocle2_reduction,
    root_state = root_states[[1]],
    root_cell_program = "Cancer_c0",
    ordering_genes = length(ordering_genes)
  )
)
