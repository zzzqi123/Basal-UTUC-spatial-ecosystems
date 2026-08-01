#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(readr)
  library(Seurat)
})

file_arg <- commandArgs(FALSE)[grep("^--file=", commandArgs(FALSE))]
file_arg <- sub("^--file=", "", file_arg)
root <- normalizePath(file.path(dirname(file_arg), ".."))
setwd(root)
test_dir <- tempfile("utuc-cibersortx-smoke-")
dir.create(test_dir, recursive = TRUE)
on.exit(unlink(test_dir, recursive = TRUE, force = TRUE), add = TRUE)

set.seed(1)
counts <- matrix(
  rpois(100 * 20, 2),
  nrow = 100,
  dimnames = list(paste0("G", seq_len(100)), paste0("C", seq_len(20)))
)
object <- CreateSeuratObject(counts)
object$second_celltype_byhand <- rep(
  c("Macro_c0_SPP1", "CAF_c3_POSTN"),
  each = 10
)
saveRDS(object, file.path(test_dir, "utuc_annotated_scrna.rds"))

bulk <- data.frame(
  GeneSymbol = paste0("G", seq_len(100)),
  matrix(
    runif(100 * 158, 14, 22),
    nrow = 100,
    dimnames = list(NULL, paste0("S", seq_len(158)))
  ),
  check.names = FALSE
)
write_tsv(bulk, file.path(test_dir, "japan_utuc_bulk_expression.tsv.gz"))

run_workflow <- function(script, output_dir) {
  output <- system2(
    "Rscript",
    c(
      script,
      "--config", "config/parameters.yaml",
      "--input-dir", test_dir,
      "--output-dir", output_dir,
      "--seed", "20260730",
      "--threads", "1"
    ),
    stdout = TRUE,
    stderr = TRUE
  )
  status <- attr(output, "status")
  if (!is.null(status) && status != 0L) {
    stop(paste(output, collapse = "\n"))
  }
}

prepared_dir <- file.path(test_dir, "prepared")
run_workflow(
  "workflows/bulk_clinical_validation/cibersortx/01_prepare_inputs.R",
  prepared_dir
)
stopifnot(
  file.exists(file.path(prepared_dir, "CIBERSORTx_scRNA_reference.txt")),
  file.exists(file.path(prepared_dir, "CIBERSORTx_bulk_mixture.txt"))
)

states <- c(
  "Macro_c0_SPP1", "CAF_c3_POSTN", "Neu_c2_VEGFA",
  "Endo_c1_CXCR4", "Cancer_c3"
)
fractions <- matrix(rexp(158 * length(states)), nrow = 158)
fractions <- fractions / rowSums(fractions)
fractions <- data.frame(
  Mixture = paste0("S", seq_len(158)),
  fractions,
  check.names = FALSE
)
names(fractions)[seq_along(states) + 1L] <- states
fractions[["P-value"]] <- runif(158)
fractions$Correlation <- runif(158, 0.8, 1)
fractions$RMSE <- runif(158, 0, 0.2)
write_csv(fractions, file.path(test_dir, "CIBERSORTx_Job2_Results.csv"))

clinical <- data.frame(
  sample_id = paste0("S", seq_len(158)),
  MI = rep(0:1, 79),
  DSS_time = seq_len(158),
  DSS_event = rep(0:1, 79),
  age = rep(60, 158),
  sex = rep(c("F", "M"), 79)
)
write_tsv(clinical, file.path(test_dir, "japan_utuc_clinical.tsv"))

imported_dir <- file.path(test_dir, "imported")
run_workflow(
  "workflows/bulk_clinical_validation/cibersortx/02_import_fractions.R",
  imported_dir
)
analysis_input <- read_tsv(
  file.path(imported_dir, "japan_utuc_program_scores.tsv"),
  show_col_types = FALSE
)
stopifnot(nrow(analysis_input) == 158L, all(states %in% names(analysis_input)))

message("PASS: CIBERSORTx reference-to-bulk hand-off smoke test")
