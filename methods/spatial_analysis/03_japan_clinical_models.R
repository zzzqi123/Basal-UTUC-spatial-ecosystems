#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(survival)
  library(tibble)
})

source(file.path("functions", "R", "cli.R"))
source(file.path("functions", "R", "analysis_helpers.R"))
opts <- parse_common_args()

input_path <- require_input(opts$input_dir, "japan_utuc_program_scores.tsv")
data <- read_tsv(input_path, show_col_types = FALSE)
required <- c(
  "sample_id", "MI", "DSS_time", "DSS_event", "age", "sex",
  "Macro_c0_SPP1", "CAF_c3_POSTN", "Neu_c2_VEGFA",
  "Endo_c1_CXCR4", "Cancer_c3"
)
missing <- setdiff(required, names(data))
if (length(missing)) stop("Japan-UTUC input missing: ", paste(missing, collapse = ", "))
if (nrow(data) != 158) stop("Expected the manuscript Japan-UTUC cohort n=158")

data <- data %>%
  mutate(
    sex = factor(sex),
    myeloid_stromal_program = safe_z(
      (rank_inverse_normal(Macro_c0_SPP1) +
         rank_inverse_normal(CAF_c3_POSTN)) / 2
    ),
    angiogenic_program = safe_z(
      (rank_inverse_normal(Neu_c2_VEGFA) +
         rank_inverse_normal(Endo_c1_CXCR4)) / 2
    ),
    cancer_c3 = safe_z(rank_inverse_normal(Cancer_c3))
  )

scores <- c("myeloid_stromal_program", "angiogenic_program", "cancer_c3")

extract_glm <- function(score_name) {
  data$score_value <- data[[score_name]]
  model <- glm(MI ~ score_value + age + sex, data = data, family = binomial())
  estimate <- coef(model)[["score_value"]]
  se <- coef(summary(model))["score_value", "Std. Error"]
  tibble(
    score = score_name,
    endpoint = "Muscle invasion",
    model = "Age/sex-adjusted",
    effect = exp(estimate),
    CI_low = exp(estimate - 1.96 * se),
    CI_high = exp(estimate + 1.96 * se),
    p_value = coef(summary(model))["score_value", "Pr(>|z|)"]
  )
}

extract_cox <- function(score_name) {
  data$score_value <- data[[score_name]]
  model <- coxph(
    Surv(DSS_time, DSS_event) ~ score_value + age + sex + MI,
    data = data,
    ties = "efron",
    x = TRUE
  )
  estimate <- coef(model)[["score_value"]]
  se <- coef(summary(model))["score_value", "se(coef)"]
  tibble(
    score = score_name,
    endpoint = "Disease-specific survival",
    model = "Age/sex/MI-adjusted",
    effect = exp(estimate),
    CI_low = exp(estimate - 1.96 * se),
    CI_high = exp(estimate + 1.96 * se),
    p_value = coef(summary(model))["score_value", "Pr(>|z|)"]
  )
}

results <- bind_rows(lapply(scores, extract_glm), lapply(scores, extract_cox)) %>%
  group_by(endpoint, model) %>%
  mutate(FDR_BH = p.adjust(p_value, method = "BH")) %>%
  ungroup()

dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
write_tsv(results, file.path(opts$output_dir, "japan_utuc_clinical_models.tsv"))
write_run_metadata(
  opts$output_dir,
  "japan_utuc_clinical_models",
  opts,
  list(unit = "per 1-SD higher rank-normalised score", cohort_n = 158)
)

