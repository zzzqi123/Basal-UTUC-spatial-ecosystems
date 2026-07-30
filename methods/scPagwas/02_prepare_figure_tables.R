#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(Seurat)
  library(dplyr)
  library(readr)
})

source(file.path("functions", "R", "cli.R"))
opts <- parse_common_args()
result_path <- require_input(opts$input_dir, "utuc_scpagwas_result.rds")
result <- readRDS(result_path)

cell_metadata <- result[[]]
required <- c("Random_Correct_BG_adjp", "scPagwas.gPAS.score")
missing <- setdiff(required, names(cell_metadata))
if (length(missing)) stop("Missing cell-level columns: ", paste(missing, collapse = ", "))

cell_table <- tibble(
  cell_id = rownames(cell_metadata),
  cell_type = as.character(Idents(result)),
  adjusted_fdr = as.numeric(cell_metadata$Random_Correct_BG_adjp),
  minus_log10_fdr = -log10(pmax(adjusted_fdr, .Machine$double.xmin)),
  gpas_score = as.numeric(cell_metadata$scPagwas.gPAS.score)
)

celltype_table <- as.data.frame(result@misc$bootstrap_results) %>%
  tibble::rownames_to_column("cell_type")
if (!"bp_value" %in% names(celltype_table)) {
  stop("Cell-type bootstrap table does not contain bp_value")
}
celltype_table <- celltype_table %>%
  transmute(
    cell_type,
    celltype_fdr = as.numeric(bp_value),
    minus_log10_celltype_fdr = -log10(pmax(celltype_fdr, .Machine$double.xmin))
  )

dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
write_tsv(cell_table, file.path(opts$output_dir, "SuppFig03B_cell_level_fdr.tsv"))
write_tsv(celltype_table, file.path(opts$output_dir, "SuppFig03C_celltype_fdr.tsv"))
write_run_metadata(opts$output_dir, "scPagwas_figure_tables", opts)

