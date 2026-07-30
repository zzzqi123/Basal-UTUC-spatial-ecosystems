#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dplyr)
  library(pROC)
  library(readr)
  library(survival)
})

source(file.path("core", "R", "cli.R"))
opts <- parse_common_args()
data <- read_tsv(
  require_input(opts$input_dir, "external_blca_bulk_scores.tsv"),
  show_col_types = FALSE
)
required <- c(
  "sample_id", "dataset", "subtype", "stage", "OS_time", "OS_event",
  "ImmuneScore", "StromalScore", "SPP1", "FAP"
)
missing <- setdiff(required, names(data))
if (length(missing)) stop("External BLCA table missing: ", paste(missing, collapse = ", "))

data <- data %>%
  mutate(
    basal = as.integer(subtype == "Basal"),
    spp1_fap_score = as.numeric(scale(SPP1)) + as.numeric(scale(FAP))
  )

roc_rows <- lapply(split(data, data$dataset), function(dataset) {
  fit <- pROC::roc(dataset$basal, dataset$spp1_fap_score, quiet = TRUE)
  tibble(
    dataset = unique(dataset$dataset),
    endpoint = "Basal subtype",
    auc = as.numeric(pROC::auc(fit))
  )
})
cox <- coxph(
  Surv(OS_time, OS_event) ~ scale(spp1_fap_score) + stage + strata(dataset),
  data = data,
  ties = "efron"
)
cox_table <- as.data.frame(coef(summary(cox)))
cox_table$term <- rownames(cox_table)

dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
write_tsv(bind_rows(roc_rows), file.path(opts$output_dir, "blca_subtype_auc.tsv"))
write_tsv(cox_table, file.path(opts$output_dir, "blca_spp1_fap_cox.tsv"))
write_run_metadata(
  opts$output_dir,
  "external_blca_bulk_validation",
  opts,
  list(cohort_handling = "dataset-stratified survival model")
)
