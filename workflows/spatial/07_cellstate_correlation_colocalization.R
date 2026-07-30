#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(tidyr)
  library(yaml)
})

source(file.path("core", "R", "cli.R"))
source(file.path("core", "R", "analysis_helpers.R"))
opts <- parse_common_args()
cfg <- yaml::read_yaml(opts$config)$spatial_colocalization
set.seed(opts$seed)

abundance <- read_tsv(
  require_input(opts$input_dir, "spatial_cellstate_abundance.tsv.gz"),
  show_col_types = FALSE
)
pairs <- read_tsv(
  require_input(opts$input_dir, "prespecified_cellstate_pairs.tsv"),
  show_col_types = FALSE
)

id_columns <- c("section", "spot_id", "array_row", "array_col", "x", "y")
required_abundance <- c("section", "spot_id")
required_pairs <- c("pair_id", "state_1", "state_2")
if (length(setdiff(required_abundance, names(abundance)))) {
  stop("Abundance table must contain section and spot_id")
}
if (length(setdiff(required_pairs, names(pairs)))) {
  stop("Pair table must contain pair_id, state_1 and state_2")
}

feature_names <- setdiff(names(abundance), id_columns)
missing_states <- setdiff(unique(c(pairs$state_1, pairs$state_2)), feature_names)
if (length(missing_states)) {
  stop("Requested cell states are absent: ", paste(missing_states, collapse = ", "))
}

correlations <- abundance %>%
  group_by(section) %>%
  group_modify(~ pairwise_spearman(.x, id_columns = id_columns)) %>%
  ungroup()

colocalization <- lapply(seq_len(nrow(pairs)), function(index) {
  pair <- pairs[index, ]
  abundance %>%
    transmute(
      section,
      spot_id,
      across(any_of(c("array_row", "array_col", "x", "y"))),
      pair_id = pair$pair_id,
      state_1 = pair$state_1,
      state_2 = pair$state_2,
      abundance_1 = .data[[pair$state_1]],
      abundance_2 = .data[[pair$state_2]],
      ordinal_1 = ordinal_abundance(.data[[pair$state_1]], cfg$ordinal_levels),
      ordinal_2 = ordinal_abundance(.data[[pair$state_2]], cfg$ordinal_levels),
      colocalization_score = ordinal_1 * ordinal_2,
      continuous_joint_abundance = sqrt(
        pmax(abundance_1, 0) * pmax(abundance_2, 0)
      )
    )
}) %>% bind_rows()

summary_table <- colocalization %>%
  group_by(section, pair_id, state_1, state_2) %>%
  summarise(
    median_ordinal_colocalization = median(colocalization_score, na.rm = TRUE),
    mean_continuous_joint_abundance = mean(
      continuous_joint_abundance,
      na.rm = TRUE
    ),
    n_spots = n(),
    .groups = "drop"
  )

dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
write_tsv(correlations, file.path(opts$output_dir, "cellstate_spearman_correlations.tsv"))
write_tsv(
  colocalization,
  file.path(opts$output_dir, "spot_cellstate_colocalization.tsv.gz")
)
write_tsv(
  summary_table,
  file.path(opts$output_dir, "section_cellstate_colocalization_summary.tsv")
)
write_run_metadata(
  opts$output_dir,
  "cellstate_correlation_and_colocalization",
  opts,
  list(
    abundance = cfg$abundance_key,
    ordinal_levels = cfg$ordinal_levels,
    ordinal_breaks = cfg$ordinal_breaks,
    interpretation = paste(
      "ordinal product reproduces manuscript maps;",
      "continuous joint abundance is reported separately"
    )
  )
)
