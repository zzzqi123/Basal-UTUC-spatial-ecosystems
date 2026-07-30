#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dplyr)
  library(mgcv)
  library(readr)
  library(tidyr)
})

source(file.path("core", "R", "cli.R"))
opts <- parse_common_args()
cfg <- yaml::read_yaml(opts$config)$spatial_multiscale
profile_path <- require_input(opts$input_dir, "posterior_mean_signed_distance.tsv")
profile <- read_tsv(profile_path, show_col_types = FALSE)

required <- c("spot_id", "sample", "signed_distance", "cell_state", "abundance")
missing <- setdiff(required, names(profile))
if (length(missing)) stop("Boundary input missing: ", paste(missing, collapse = ", "))

profile <- profile %>%
  group_by(sample, cell_state) %>%
  mutate(abundance_z = as.numeric(scale(log1p(abundance)))) %>%
  ungroup() %>%
  filter(
    is.finite(signed_distance),
    is.finite(abundance_z),
    signed_distance >= cfg$signed_distance_min,
    signed_distance <= cfg$signed_distance_max
  ) %>%
  mutate(distance_bin = round(signed_distance)) %>%
  group_by(sample, cell_state, distance_bin) %>%
  summarise(
    signed_distance = median(signed_distance),
    abundance_z = median(abundance_z),
    n_spots = n(),
    .groups = "drop"
  )

prediction_grid <- profile %>%
  distinct(sample, cell_state) %>%
  tidyr::crossing(
    signed_distance = seq(
      cfg$signed_distance_min,
      cfg$signed_distance_max,
      by = 0.1
    )
  )

fit_one <- function(sample_name, state_name) {
  subset <- profile %>%
    filter(sample == sample_name, cell_state == state_name)
  model <- mgcv::gam(
    abundance_z ~ s(signed_distance, k = cfg$gam_basis_dimension),
    data = subset,
    method = "REML"
  )
  grid <- prediction_grid %>%
    filter(sample == sample_name, cell_state == state_name)
  prediction <- predict(model, newdata = grid, se.fit = TRUE)
  grid$fitted_z <- as.numeric(prediction$fit)
  grid$se <- as.numeric(prediction$se.fit)
  grid
}

keys <- profile %>% distinct(sample, cell_state)
predictions <- bind_rows(Map(fit_one, keys$sample, keys$cell_state))
dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
write_tsv(predictions, file.path(opts$output_dir, "section_boundary_predictions.tsv"))
write_run_metadata(
  opts$output_dir,
  "posterior_mean_boundary_profiles",
  opts,
  list(
    abundance_summary = "posterior_mean",
    pooling = "none; fitted separately by section",
    signed_distance_range = paste(
      cfg$signed_distance_min,
      "to",
      cfg$signed_distance_max,
      "spot spacings"
    ),
    profile_input = "binned medians of within-section log1p-standardized abundance"
  )
)
