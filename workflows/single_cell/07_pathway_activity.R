#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(AUCell)
  library(GSVA)
  library(decoupleR)
  library(readr)
  library(Seurat)
})

source(file.path("core", "R", "cli.R"))
opts <- parse_common_args()
object <- readRDS(require_input(opts$input_dir, "utuc_scrna_annotated.rds"))
gene_sets <- readRDS(require_input(opts$input_dir, "curated_gene_sets.rds"))
if (!inherits(object, "Seurat")) stop("Input must be a Seurat object")
if (!is.list(gene_sets) || !length(gene_sets)) stop("Gene sets must be a named list")

expression <- as.matrix(GetAssayData(object, assay = "RNA", layer = "data"))
rankings <- AUCell_buildRankings(expression, plotStats = FALSE, nCores = opts$threads)
aucell <- AUCell_calcAUC(gene_sets, rankings, nCores = opts$threads)
aucell_table <- as.data.frame(t(getAUC(aucell)))
aucell_table$cell_id <- rownames(aucell_table)

# PROGENy is run through decoupleR so that pathway weights and the returned
# per-cell activity table are explicit and versionable.
progeny_network <- decoupleR::get_progeny(
  organism = "human",
  top = 500
)
progeny <- decoupleR::run_mlm(
  mat = expression,
  network = progeny_network,
  .source = "source",
  .target = "target",
  .mor = "weight",
  minsize = 5
)

dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
write_tsv(aucell_table, file.path(opts$output_dir, "aucell_cell_scores.tsv"))
write_tsv(progeny, file.path(opts$output_dir, "progeny_cell_scores.tsv"))
write_run_metadata(
  opts$output_dir,
  "single_cell_pathway_activity",
  opts,
  list(
    methods = c("AUCell", "PROGENy via decoupleR"),
    progeny_top_genes = 500,
    progeny_min_size = 5
  )
)
