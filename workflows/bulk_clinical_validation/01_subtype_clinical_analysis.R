#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dplyr)
  library(pROC)
  library(readr)
  library(survival)
  library(survminer)
  library(tibble)
  library(timeROC)
  library(yaml)
})

source(file.path("core", "R", "cli.R"))
opts <- parse_common_args()
cfg <- yaml::read_yaml(opts$config)$bulk_clinical
set.seed(opts$seed)

data <- read_tsv(
  require_input(opts$input_dir, "utuc_bulk_expression_clinical.tsv"),
  show_col_types = FALSE
)
required <- c(
  "sample_id", "subtype", "stage", "DSS_time", "DSS_event",
  "SPP1", "FAP", "KRT5", "GATA3"
)
missing <- setdiff(required, names(data))
if (length(missing)) stop("Bulk input missing: ", paste(missing, collapse = ", "))

data <- data %>%
  mutate(
    basal = as.integer(subtype == "Basal"),
    stage = factor(stage),
    spp1_fap_score = as.numeric(scale(SPP1)) + as.numeric(scale(FAP)),
    spp1_fap_group = interaction(
      ifelse(SPP1 >= median(SPP1, na.rm = TRUE), "SPP1high", "SPP1low"),
      ifelse(FAP >= median(FAP, na.rm = TRUE), "FAPhigh", "FAPlow"),
      sep = "_"
    )
  )

marker_names <- c("SPP1", "FAP", "KRT5", "GATA3", "spp1_fap_score")
roc_results <- lapply(marker_names, function(marker) {
  fit <- pROC::roc(data$basal, data[[marker]], quiet = TRUE)
  coordinates <- as.data.frame(pROC::coords(
    fit,
    x = "all",
    ret = c("threshold", "specificity", "sensitivity")
  ))
  list(
    summary = tibble(
      marker = marker,
      endpoint = "Basal subtype",
      auc = as.numeric(pROC::auc(fit))
    ),
    curve = coordinates %>%
      transmute(
        marker = marker,
        threshold,
        fpr = 1 - specificity,
        tpr = sensitivity
      )
  )
})

survival_results <- lapply(c("SPP1", "FAP", "spp1_fap_score"), function(marker) {
  cutpoint_result <- surv_cutpoint(
    data,
    time = "DSS_time",
    event = "DSS_event",
    variables = marker,
    minprop = cfg$maximally_selected_min_fraction
  )
  cutpoint <- cutpoint_result$cutpoint[marker, "cutpoint"]
  group <- factor(
    ifelse(data[[marker]] > cutpoint, "high", "low"),
    levels = c("low", "high")
  )
  model_data <- mutate(
    data,
    marker_value = .data[[marker]],
    marker_group = group
  )
  km_fit <- survfit(
    Surv(DSS_time, DSS_event) ~ marker_group,
    data = model_data
  )
  km_summary <- summary(km_fit)
  logrank <- survdiff(
    Surv(DSS_time, DSS_event) ~ marker_group,
    data = model_data
  )
  logrank_p <- pchisq(logrank$chisq, df = 1, lower.tail = FALSE)
  univariable <- coxph(
    Surv(DSS_time, DSS_event) ~ scale(marker_value),
    data = model_data,
    ties = "efron"
  )
  multivariable <- coxph(
    Surv(DSS_time, DSS_event) ~ scale(marker_value) + stage,
    data = model_data,
    ties = "efron"
  )
  time_roc <- timeROC(
    T = data$DSS_time,
    delta = data$DSS_event,
    marker = data[[marker]],
    cause = 1,
    weighting = "marginal",
    times = cfg$survival_time_horizon,
    iid = TRUE
  )
  list(
    summary = tibble(
      marker = marker,
      cutpoint = cutpoint,
      cutpoint_method = "maximally_selected_rank",
      logrank_p = logrank_p,
      time_horizon = cfg$survival_time_horizon,
      time_dependent_auc = unname(time_roc$AUC[[1]])
    ),
    km = tibble(
      marker = marker,
      time = km_summary$time,
      survival = km_summary$surv,
      standard_error = km_summary$std.err,
      lower = km_summary$lower,
      upper = km_summary$upper,
      group = sub("^marker_group=", "", km_summary$strata)
    ),
    cox = bind_rows(
      as.data.frame(coef(summary(univariable))) %>%
        rownames_to_column("term") %>%
        mutate(marker = marker, model = "univariable"),
      as.data.frame(coef(summary(multivariable))) %>%
        rownames_to_column("term") %>%
        mutate(marker = marker, model = "stage_adjusted")
    )
  )
})

joint_km_fit <- survfit(
  Surv(DSS_time, DSS_event) ~ spp1_fap_group,
  data = data
)
joint_km_summary <- summary(joint_km_fit)
joint_cox <- coxph(
  Surv(DSS_time, DSS_event) ~ spp1_fap_group + stage,
  data = data,
  ties = "efron"
)

dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
write_tsv(
  bind_rows(lapply(roc_results, `[[`, "summary")),
  file.path(opts$output_dir, "subtype_roc_auc.tsv")
)
write_tsv(
  bind_rows(lapply(roc_results, `[[`, "curve")),
  file.path(opts$output_dir, "subtype_roc_curves.tsv.gz")
)
write_tsv(
  bind_rows(lapply(survival_results, `[[`, "summary")),
  file.path(opts$output_dir, "dss_cutpoint_logrank_timeroc.tsv")
)
write_tsv(
  bind_rows(lapply(survival_results, `[[`, "cox")),
  file.path(opts$output_dir, "dss_cox_models.tsv")
)
write_tsv(
  bind_rows(lapply(survival_results, `[[`, "km")),
  file.path(opts$output_dir, "dss_km_curves.tsv.gz")
)
write_tsv(
  tibble(
    time = joint_km_summary$time,
    survival = joint_km_summary$surv,
    standard_error = joint_km_summary$std.err,
    lower = joint_km_summary$lower,
    upper = joint_km_summary$upper,
    group = sub("^spp1_fap_group=", "", joint_km_summary$strata)
  ),
  file.path(opts$output_dir, "spp1_fap_joint_km_curve.tsv")
)
write_tsv(
  as.data.frame(coef(summary(joint_cox))) %>% rownames_to_column("term"),
  file.path(opts$output_dir, "spp1_fap_joint_stage_adjusted_cox.tsv")
)
write_tsv(
  select(data, sample_id, subtype, stage, spp1_fap_score, spp1_fap_group),
  file.path(opts$output_dir, "spp1_fap_groups.tsv")
)
write_run_metadata(
  opts$output_dir,
  "bulk_subtype_clinical_analysis",
  opts,
  list(
    primary_endpoint = "DSS",
    survival_time_horizon = cfg$survival_time_horizon,
    survival_time_unit = cfg$survival_time_unit,
    ties = "efron"
  )
)
