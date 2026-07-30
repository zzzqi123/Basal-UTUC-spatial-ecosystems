#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dplyr)
  library(mgcv)
  library(readr)
  library(tidyr)
  library(yaml)
})

source(file.path("core", "R", "cli.R"))
source(file.path("core", "R", "analysis_helpers.R"))
opts <- parse_common_args()
config <- yaml::read_yaml(opts$config)
cfg <- config$external_spatial_validation
set.seed(opts$seed)

spot_table <- read_tsv(
  require_input(opts$input_dir, "external_visium_spot_scores.tsv.gz"),
  show_col_types = FALSE
)
required <- c(
  "section", "spot_id", "basal_score", "luminal_score",
  "epithelial_proportion", "dominant_celltype",
  "spp1_tam_proportion", "fap_mycaf_proportion", "ring"
)
if (length(setdiff(required, names(spot_table)))) {
  stop("External Visium table is missing required score or RCTD columns")
}

anchors <- spot_table %>%
  filter(
    dominant_celltype == "Epithelial",
    epithelial_proportion > config$rctd$epithelial_anchor_fraction
  ) %>%
  group_by(section, ring) %>%
  mutate(
    basal_z = safe_z(basal_score),
    luminal_z = safe_z(luminal_score),
    basal_luminal_axis = basal_z - luminal_z,
    basal_axis_percentile = percent_rank(basal_luminal_axis),
    tam_mycaf_burden = sqrt(
      pmax(spp1_tam_proportion, 0) * pmax(fap_mycaf_proportion, 0)
    ),
    tam_mycaf_burden_z = safe_z(log1p(tam_mycaf_burden))
  ) %>%
  ungroup() %>%
  filter(
    basal_axis_percentile >= cfg$basal_axis_trim_quantiles[[1]],
    basal_axis_percentile <= cfg$basal_axis_trim_quantiles[[2]]
  )

curves <- anchors %>%
  group_by(section, ring) %>%
  group_modify(function(data, keys) {
    fit <- mgcv::gam(
      tam_mycaf_burden_z ~ s(basal_axis_percentile, k = 6),
      data = data,
      method = "REML"
    )
    grid <- data.frame(basal_axis_percentile = seq(0.05, 0.95, length.out = 91))
    prediction <- predict(fit, newdata = grid, se.fit = TRUE)
    transform(
      grid,
      fitted = as.numeric(prediction$fit),
      se = as.numeric(prediction$se.fit),
      lower = fitted - 1.96 * se,
      upper = fitted + 1.96 * se
    )
  }) %>%
  ungroup()

bootstrap_curve <- function(data, iterations) {
  matrix_wide <- data %>%
    select(section, basal_axis_percentile, fitted) %>%
    pivot_wider(
      names_from = basal_axis_percentile,
      values_from = fitted,
      names_sort = TRUE
    )
  section_ids <- matrix_wide$section
  fitted_matrix <- as.matrix(matrix_wide[, -1, drop = FALSE])
  if (length(section_ids) < 2L) {
    stop("At least two sections are required for section bootstrap")
  }
  bootstrap_means <- replicate(iterations, {
    sampled <- sample(seq_along(section_ids), replace = TRUE)
    colMeans(fitted_matrix[sampled, , drop = FALSE], na.rm = TRUE)
  })
  data.frame(
    basal_axis_percentile = as.numeric(colnames(fitted_matrix)),
    mean_curve = colMeans(fitted_matrix, na.rm = TRUE),
    ci_low = apply(bootstrap_means, 1, quantile, probs = 0.025, na.rm = TRUE),
    ci_high = apply(bootstrap_means, 1, quantile, probs = 0.975, na.rm = TRUE)
  )
}

mean_curves <- curves %>%
  group_by(ring) %>%
  group_modify(~ bootstrap_curve(.x, cfg$section_bootstraps)) %>%
  ungroup()

effects <- anchors %>%
  mutate(
    axis_quartile = case_when(
      basal_axis_percentile <= 0.25 ~ "lower",
      basal_axis_percentile >= 0.75 ~ "upper",
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(axis_quartile)) %>%
  group_by(section, ring, axis_quartile) %>%
  summarise(mean_burden = mean(tam_mycaf_burden_z), .groups = "drop") %>%
  pivot_wider(names_from = axis_quartile, values_from = mean_burden) %>%
  mutate(upper_minus_lower = upper - lower)

tests <- effects %>%
  group_by(ring) %>%
  summarise(
    n_sections = n(),
    median_effect = median(upper_minus_lower),
    p_value = if (n() >= 3) {
      wilcox.test(upper_minus_lower, mu = 0, exact = FALSE)$p.value
    } else {
      NA_real_
    },
    .groups = "drop"
  ) %>%
  mutate(fdr = p.adjust(p_value, method = "BH"))

effect_bootstrap <- effects %>%
  group_by(ring) %>%
  group_modify(function(data, keys) {
    values <- data$upper_minus_lower
    bootstrap_means <- replicate(
      cfg$section_bootstraps,
      mean(sample(values, replace = TRUE), na.rm = TRUE)
    )
    data.frame(
      mean_effect = mean(values, na.rm = TRUE),
      ci_low = quantile(bootstrap_means, 0.025, na.rm = TRUE),
      ci_high = quantile(bootstrap_means, 0.975, na.rm = TRUE)
    )
  }) %>%
  ungroup()

dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
write_tsv(anchors, file.path(opts$output_dir, "external_visium_epithelial_anchors.tsv.gz"))
write_tsv(curves, file.path(opts$output_dir, "external_visium_section_gam_curves.tsv.gz"))
write_tsv(mean_curves, file.path(opts$output_dir, "external_visium_mean_gam_curves.tsv"))
write_tsv(effects, file.path(opts$output_dir, "external_visium_section_effects.tsv"))
write_tsv(tests, file.path(opts$output_dir, "external_visium_ring_tests.tsv"))
write_tsv(
  effect_bootstrap,
  file.path(opts$output_dir, "external_visium_effect_bootstrap.tsv")
)
write_run_metadata(
  opts$output_dir,
  "external_visium_basal_axis_validation",
  opts,
  list(
    epithelial_fraction = config$rctd$epithelial_anchor_fraction,
    sections_expected = 22,
    section_weighting = "equal",
    section_bootstraps = cfg$section_bootstraps
  )
)
