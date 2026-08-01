#!/usr/bin/env Rscript

# Validate CIBERSORTx Job 2 fractions and create the de-identified patient-level
# table consumed by the Japan-UTUC clinical models.

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(yaml)
})

source(file.path("core", "R", "cli.R"))
opts <- parse_common_args()
cfg <- yaml::read_yaml(opts$config)$cibersortx

fractions_path <- require_input(opts$input_dir, "CIBERSORTx_Job2_Results.csv")
clinical_path <- require_input(opts$input_dir, "japan_utuc_clinical.tsv")
fractions <- read_csv(fractions_path, show_col_types = FALSE, name_repair = "minimal")
clinical <- read_tsv(clinical_path, show_col_types = FALSE)

sample_column <- intersect(c("Mixture", "SampleID", "sample_id"), names(fractions))[1]
if (is.na(sample_column)) stop("CIBERSORTx output lacks the mixture/sample column")
names(fractions)[names(fractions) == sample_column] <- "sample_id"
qc_columns <- intersect(c("P-value", "Correlation", "RMSE", "Absolute score"), names(fractions))
fraction_columns <- setdiff(names(fractions), c("sample_id", qc_columns))
required_states <- c(
  "Macro_c0_SPP1", "CAF_c3_POSTN", "Neu_c2_VEGFA",
  "Endo_c1_CXCR4", "Cancer_c3"
)
missing_states <- setdiff(required_states, fraction_columns)
if (length(missing_states)) {
  stop("CIBERSORTx output lacks final cell states: ", paste(missing_states, collapse = ", "))
}
if (nrow(fractions) != cfg$expected_bulk_samples) {
  stop("Unexpected CIBERSORTx sample count: ", nrow(fractions))
}
if (anyDuplicated(fractions$sample_id)) stop("Duplicated CIBERSORTx sample IDs")

fraction_matrix <- as.matrix(fractions[, fraction_columns, drop = FALSE])
storage.mode(fraction_matrix) <- "numeric"
if (any(!is.finite(fraction_matrix)) || any(fraction_matrix < 0)) {
  stop("CIBERSORTx fractions must be finite and non-negative")
}
fraction_sums <- rowSums(fraction_matrix)
if (any(abs(fraction_sums - 1) > cfg$relative_sum_tolerance)) {
  stop("Relative CIBERSORTx fractions do not sum to one within tolerance")
}

required_clinical <- c(
  "sample_id", "MI", "DSS_time", "DSS_event", "age", "sex"
)
missing_clinical <- setdiff(required_clinical, names(clinical))
if (length(missing_clinical)) {
  stop("Clinical table lacks: ", paste(missing_clinical, collapse = ", "))
}
if (!setequal(fractions$sample_id, clinical$sample_id)) {
  stop("Clinical and CIBERSORTx sample IDs do not match exactly")
}

proportions <- fractions %>% select(sample_id, all_of(fraction_columns))
analysis_input <- clinical %>%
  inner_join(proportions, by = "sample_id") %>%
  select(all_of(required_clinical), all_of(required_states))
qc <- fractions %>%
  select(sample_id, any_of(qc_columns)) %>%
  mutate(fraction_sum = fraction_sums)

dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
write_tsv(
  proportions,
  file.path(opts$output_dir, "japan_utuc_cibersortx_proportions.tsv")
)
write_tsv(
  analysis_input,
  file.path(opts$output_dir, "japan_utuc_program_scores.tsv")
)
write_tsv(qc, file.path(opts$output_dir, "cibersortx_job2_qc.tsv"))
write_run_metadata(
  opts$output_dir,
  "cibersortx_fraction_import",
  opts,
  list(
    cohort_n = nrow(analysis_input),
    cell_states = length(fraction_columns),
    mode = "relative fractions",
    downstream = "Japan-UTUC muscle-invasion and DSS models"
  )
)
