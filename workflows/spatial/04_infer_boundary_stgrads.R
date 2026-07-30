#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(stGrads)
  library(tidyr)
})

source(file.path("core", "R", "cli.R"))
opts <- parse_common_args()
cfg <- yaml::read_yaml(opts$config)$spatial_multiscale
metadata <- read_tsv(
  require_input(opts$input_dir, "stgrads_interface_input.tsv"),
  show_col_types = FALSE
)

required <- c(
  "spot_id", "sample", "x_nn", "y_nn", "malignant_fraction", "tumor_type"
)
missing <- setdiff(required, names(metadata))
if (length(missing)) stop("stGrads input missing: ", paste(missing, collapse = ", "))

interface <- stg_tumor_interface(
  metadata = metadata,
  sample_col = "sample",
  type_col = "tumor_type",
  x_col = "x_nn",
  y_col = "y_nn",
  tumor_label = "Tumor",
  interface_width = cfg$interface_width
)

state_columns <- intersect(
  c(
    "Macro_c0_SPP1", "CAF_c3_POSTN", "Neu_c2_VEGFA",
    "Endo_c1_CXCR4", "Cancer_c3"
  ),
  names(interface)
)
long <- interface %>%
  select(
    spot_id, sample, malignant_fraction,
    tumor_interface_signed_distance, tumor_interface_zone,
    all_of(state_columns)
  ) %>%
  pivot_longer(
    cols = all_of(state_columns),
    names_to = "cell_state",
    values_to = "abundance"
  ) %>%
  rename(signed_distance = tumor_interface_signed_distance)

dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
write_tsv(interface, file.path(opts$output_dir, "stgrads_signed_interface_spots.tsv"))
write_tsv(long, file.path(opts$output_dir, "posterior_mean_signed_distance.tsv"))
write_run_metadata(
  opts$output_dir,
  "stgrads_signed_tumor_interface",
  opts,
  list(
    interface_width = cfg$interface_width,
    negative_side = "tumor",
    positive_side = "non-tumor",
    distance_unit = "median Visium spot spacing"
  )
)
