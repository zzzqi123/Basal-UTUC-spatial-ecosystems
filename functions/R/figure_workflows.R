suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(yaml)
})

source(file.path("functions", "R", "analysis_helpers.R"))

run_configured_analysis <- function(module_id, cfg, opts) {
  dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
  workflow <- cfg$workflow
  input_file <- file.path(opts$input_dir, cfg$input_file)
  if (!file.exists(input_file)) {
    stop(
      "Input required for ", module_id, " is not distributed in this repository: ",
      input_file, "\nSee data/README.md and manifests/data_manifest.tsv."
    )
  }
  data <- readr::read_tsv(input_file, show_col_types = FALSE)

  if (workflow == "cell_composition") {
    output <- cell_proportions(data, cfg$group_column, cfg$celltype_column)
  } else if (workflow == "group_summary") {
    output <- summarise_numeric_by_group(data, cfg$group_columns)
  } else if (workflow == "marker_filter") {
    output <- data %>%
      filter(
        .data[[cfg$fdr_column]] <= cfg$fdr_threshold,
        abs(.data[[cfg$effect_column]]) >= cfg$effect_threshold
      ) %>%
      arrange(.data[[cfg$fdr_column]])
  } else if (workflow == "spatial_pair_burden") {
    output <- data %>%
      mutate(
        pair_burden = pair_burden(
          .data[[cfg$first_state]],
          .data[[cfg$second_state]],
          cfg$pair_method
        )
      ) %>%
      group_by(across(all_of(cfg$group_columns))) %>%
      summarise(
        median_pair_burden = median(pair_burden, na.rm = TRUE),
        mean_pair_burden = mean(pair_burden, na.rm = TRUE),
        n_spots = n(),
        .groups = "drop"
      )
  } else if (workflow == "precomputed_results") {
    required <- cfg$required_columns
    missing <- setdiff(required, names(data))
    if (length(missing)) stop("Missing columns: ", paste(missing, collapse = ", "))
    output <- data %>% select(all_of(required))
  } else {
    stop("Unsupported workflow in ", module_id, ": ", workflow)
  }

  output_path <- file.path(opts$output_dir, cfg$analysis_output)
  readr::write_tsv(output, output_path)
  output_path
}

run_configured_plot <- function(module_id, cfg, opts) {
  source(file.path("functions", "R", "plot_helpers.R"))
  input_path <- file.path(opts$input_dir, cfg$plot_input)
  if (!file.exists(input_path)) stop("Plot input not found: ", input_path)
  data <- readr::read_tsv(input_path, show_col_types = FALSE)
  if (!all(c(cfg$x, cfg$y) %in% names(data))) {
    stop("Plot columns not found for ", module_id)
  }
  plot <- plot_group_summary(
    data,
    x = cfg$x,
    y = cfg$y,
    color = cfg$color,
    title = cfg$title
  )
  save_vector_plot(
    plot,
    file.path(opts$output_dir, cfg$plot_output),
    width = cfg$width,
    height = cfg$height
  )
}

