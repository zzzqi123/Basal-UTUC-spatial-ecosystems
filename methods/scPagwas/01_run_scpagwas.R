#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(Seurat)
  library(scPagwas)
  library(yaml)
})

source(file.path("functions", "R", "cli.R"))
opts <- parse_common_args()
cfg_all <- yaml::read_yaml(opts$config)
cfg <- cfg_all$scPagwas
set.seed(opts$seed)

if (!identical(cfg$entrypoint, "scPagwas_main")) {
  stop("This release is locked to the original scPagwas_main workflow")
}
if (!identical(cfg$genome_build, "GRCh38")) {
  stop("The manuscript specifies GRCh38; check GWAS and block annotation build")
}

single_path <- require_input(opts$input_dir, "utuc_scrna_seurat.rds")
gwas_path <- require_input(opts$input_dir, "finngen_r12_utuc.tsv.gz")
object <- readRDS(single_path)
if (!inherits(object, "Seurat")) stop("Single-cell input must be a Seurat object")
if (!cfg$assay %in% Assays(object)) stop("Assay not found: ", cfg$assay)
if (is.null(Idents(object))) stop("Seurat Idents must contain cell-type labels")

required_gwas <- c("chrom", "pos", "rsid", "se", "beta", "maf")
gwas_header <- names(readr::read_tsv(gwas_path, n_max = 1, show_col_types = FALSE))
missing_gwas <- setdiff(required_gwas, gwas_header)
if (length(missing_gwas)) {
  stop("GWAS columns missing: ", paste(missing_gwas, collapse = ", "))
}

output_prefix <- "UTUC_FinnGen_R12"
package_data <- new.env(parent = emptyenv())
for (dataset_name in c("block_annotation", "Genes_by_pathway_kegg", "chrom_ld")) {
  utils::data(
    list = dataset_name,
    package = "scPagwas",
    envir = package_data
  )
  if (!exists(dataset_name, envir = package_data, inherits = FALSE)) {
    stop("Required scPagwas reference dataset is unavailable: ", dataset_name)
  }
}

result <- scPagwas::scPagwas_main(
  Pagwas = NULL,
  gwas_data = gwas_path,
  Single_data = object,
  output.prefix = output_prefix,
  output.dirs = opts$output_dir,
  block_annotation = package_data$block_annotation,
  assay = cfg$assay,
  Pathway_list = package_data$Genes_by_pathway_kegg,
  chrom_ld = package_data$chrom_ld,
  n.cores = opts$threads,
  marg = as.integer(cfg$marg),
  maf_filter = as.numeric(cfg$maf_filter),
  min_clustercells = as.integer(cfg$min_cluster_cells),
  min.pathway.size = as.integer(cfg$min_pathway_size),
  max.pathway.size = as.integer(cfg$max_pathway_size),
  iters_celltype = as.integer(cfg$iterations_celltype),
  iters_singlecell = as.integer(cfg$iterations_singlecell),
  n_topgenes = as.integer(cfg$top_genes),
  singlecell = isTRUE(cfg$singlecell),
  celltype = isTRUE(cfg$celltype),
  seurat_return = TRUE,
  remove_outlier = isTRUE(cfg$remove_outlier)
)

required_cell_columns <- c(
  "Random_Correct_BG_p",
  "Random_Correct_BG_adjp",
  "Random_Correct_BG_z"
)
missing_cell_columns <- setdiff(required_cell_columns, colnames(result[[]]))
if (length(missing_cell_columns)) {
  stop("scPagwas cell-level results missing: ",
       paste(missing_cell_columns, collapse = ", "))
}
if (is.null(result@misc$bootstrap_results)) {
  stop("scPagwas cell-type bootstrap results were not returned")
}

saveRDS(result, file.path(opts$output_dir, "utuc_scpagwas_result.rds"))
write_run_metadata(
  opts$output_dir,
  "scPagwas_main",
  opts,
  list(
    genome_build = cfg$genome_build,
    gwas_release = cfg$gwas_release,
    iters_celltype = cfg$iterations_celltype,
    iters_singlecell = cfg$iterations_singlecell,
    multiple_testing = cfg$multiple_testing
  )
)
