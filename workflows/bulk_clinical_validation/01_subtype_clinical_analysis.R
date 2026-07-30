#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dplyr)
  library(pROC)
  library(readr)
  library(survival)
  library(tibble)
})

source(file.path("core", "R", "cli.R"))
opts <- parse_common_args()
data <- read_tsv(require_input(opts$input_dir, "japan_utuc_expression_clinical.tsv"),
                 show_col_types = FALSE)
required <- c("sample_id", "subtype", "stage", "DSS_time", "DSS_event", "SPP1", "FAP", "KRT5", "GATA3")
missing <- setdiff(required, names(data))
if (length(missing)) stop("Bulk input missing: ", paste(missing, collapse = ", "))

data <- data %>%
  mutate(
    basal = as.integer(subtype == "Basal"),
    stage = factor(stage),
    spp1_fap_group = interaction(
      ifelse(SPP1 >= median(SPP1, na.rm = TRUE), "SPP1high", "SPP1low"),
      ifelse(FAP >= median(FAP, na.rm = TRUE), "FAPhigh", "FAPlow"),
      sep = "_"
    )
  )

roc_results <- bind_rows(lapply(c("SPP1", "FAP", "KRT5", "GATA3"), function(gene) {
  fit <- pROC::roc(data$basal, data[[gene]], quiet = TRUE)
  tibble(marker = gene, auc = as.numeric(pROC::auc(fit)))
}))

cox <- coxph(
  Surv(DSS_time, DSS_event) ~ spp1_fap_group + stage,
  data = data,
  ties = "efron"
)
cox_table <- as.data.frame(coef(summary(cox))) %>%
  rownames_to_column("term")

dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
write_tsv(roc_results, file.path(opts$output_dir, "subtype_roc_auc.tsv"))
write_tsv(cox_table, file.path(opts$output_dir, "spp1_fap_cox_model.tsv"))
write_run_metadata(opts$output_dir, "bulk_subtype_clinical_analysis", opts)

