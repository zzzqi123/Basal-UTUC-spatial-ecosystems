suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(readr)
  library(tidyr)
})

source(file.path("core", "R", "analysis_helpers.R"))
source(file.path("core", "R", "plot_helpers.R"))

# Figure scripts declare their panel-specific work as a list of small records.
# Heavy model fitting remains in workflows/; this layer checks the public table
# interface, performs light panel statistics, and writes one table per panel.

read_panel_input <- function(input_dir, spec) {
  path <- file.path(input_dir, spec$input)
  if (!file.exists(path)) {
    stop(
      "Missing input for panel ", spec$panel, ": ", path,
      "\nGenerate it with: ", spec$workflow
    )
  }
  data <- readr::read_tsv(path, show_col_types = FALSE)
  missing <- setdiff(spec$required, names(data))
  if (length(missing)) {
    stop(
      "Panel ", spec$panel, " is missing columns: ",
      paste(missing, collapse = ", ")
    )
  }
  data
}

run_panel_operation <- function(data, spec) {
  operation <- spec$operation
  if (operation == "select") {
    return(data %>% select(all_of(spec$required)))
  }
  if (operation == "group_summary") {
    return(summarise_numeric_by_group(data, spec$groups))
  }
  if (operation == "cell_proportion") {
    return(cell_proportions(data, spec$groups[[1]], spec$cell_type))
  }
  if (operation == "filter_fdr") {
    return(
      data %>%
        filter(
          .data[[spec$fdr]] <= spec$fdr_cutoff,
          abs(.data[[spec$effect]]) >= spec$effect_cutoff
        ) %>%
        arrange(.data[[spec$fdr]])
    )
  }
  if (operation == "correlation") {
    result <- stats::cor.test(
      data[[spec$x]],
      data[[spec$y]],
      method = spec$method %||% "spearman",
      exact = FALSE
    )
    return(
      tibble(
        x = spec$x,
        y = spec$y,
        method = result$method,
        estimate = unname(result$estimate),
        p_value = result$p.value,
        n = sum(stats::complete.cases(data[c(spec$x, spec$y)]))
      )
    )
  }
  if (operation == "spatial_pair_summary") {
    return(
      data %>%
        group_by(across(all_of(spec$groups))) %>%
        summarise(
          median_pair_burden = median(.data[[spec$value]], na.rm = TRUE),
          mean_pair_burden = mean(.data[[spec$value]], na.rm = TRUE),
          n_spots = n(),
          .groups = "drop"
        )
    )
  }
  if (operation == "top_ranked") {
    return(
      data %>%
        arrange(.data[[spec$order_by]]) %>%
        slice_head(n = spec$n %||% 20L)
    )
  }
  stop("Unsupported panel operation: ", operation)
}

run_figure_analysis <- function(module_id, panel_plan, opts) {
  dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
  audit_rows <- vector("list", length(panel_plan))

  for (index in seq_along(panel_plan)) {
    spec <- panel_plan[[index]]
    if (identical(spec$operation, "document_only")) {
      audit_rows[[index]] <- tibble(
        panel = spec$panel,
        workflow = spec$workflow,
        input = NA_character_,
        output = NA_character_,
        status = "documented_noncomputational_panel"
      )
      next
    }
    data <- read_panel_input(opts$input_dir, spec)
    output <- run_panel_operation(data, spec)
    output_name <- spec$output %||% paste0("panel_", spec$panel, "_data.tsv")
    readr::write_tsv(output, file.path(opts$output_dir, output_name))
    audit_rows[[index]] <- tibble(
      panel = spec$panel,
      workflow = spec$workflow,
      input = spec$input,
      output = output_name,
      status = "written"
    )
  }

  audit <- bind_rows(audit_rows)
  readr::write_tsv(audit, file.path(opts$output_dir, "panel_output_manifest.tsv"))
  invisible(audit)
}

panel_plot <- function(data, spec) {
  geometry <- spec$geometry
  if (geometry == "box") {
    plot <- ggplot(data, aes(x = .data[[spec$x]], y = .data[[spec$y]])) +
      geom_boxplot(outlier.shape = NA, width = 0.62) +
      geom_jitter(width = 0.12, alpha = 0.55, size = 1)
  } else if (geometry == "bar") {
    plot <- ggplot(data, aes(x = .data[[spec$x]], y = .data[[spec$y]])) +
      geom_col(width = 0.72)
  } else if (geometry == "point") {
    plot <- ggplot(data, aes(x = .data[[spec$x]], y = .data[[spec$y]])) +
      geom_point(size = 1.6, alpha = 0.75)
  } else if (geometry == "line") {
    plot <- ggplot(data, aes(x = .data[[spec$x]], y = .data[[spec$y]])) +
      geom_line(aes(group = .data[[spec$group]]), linewidth = 0.8) +
      geom_point(size = 1.2)
  } else if (geometry == "heatmap") {
    plot <- ggplot(
      data,
      aes(x = .data[[spec$x]], y = .data[[spec$y]], fill = .data[[spec$fill]])
    ) +
      geom_tile()
  } else if (geometry == "forest") {
    plot <- ggplot(
      data,
      aes(x = .data[[spec$effect]], y = .data[[spec$term]])
    ) +
      geom_vline(xintercept = 1, linetype = 2, colour = "grey50") +
      geom_errorbarh(
        aes(xmin = .data[[spec$lower]], xmax = .data[[spec$upper]]),
        height = 0.18
      ) +
      geom_point(size = 2)
  } else {
    stop("Unsupported plot geometry: ", geometry)
  }

  if (!is.null(spec$colour)) {
    plot <- plot + aes(colour = .data[[spec$colour]])
  }
  if (!is.null(spec$fill)) {
    plot <- plot + aes(fill = .data[[spec$fill]])
  }
  if (!is.null(spec$facet)) {
    plot <- plot + facet_wrap(stats::as.formula(paste("~", spec$facet)))
  }
  plot +
    labs(title = spec$title, x = spec$x_label %||% NULL, y = spec$y_label %||% NULL) +
    publication_theme()
}

run_figure_plots <- function(module_id, plot_plan, opts) {
  dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
  plot_rows <- vector("list", length(plot_plan))

  for (index in seq_along(plot_plan)) {
    spec <- plot_plan[[index]]
    input_path <- file.path(opts$input_dir, spec$input)
    if (!file.exists(input_path)) {
      stop("Missing plotting table for panel ", spec$panel, ": ", input_path)
    }
    data <- readr::read_tsv(input_path, show_col_types = FALSE)
    plot <- panel_plot(data, spec)
    output_name <- spec$output %||% paste0("panel_", spec$panel, ".pdf")
    save_vector_plot(
      plot,
      file.path(opts$output_dir, output_name),
      width = spec$width %||% 5.5,
      height = spec$height %||% 4.2
    )
    plot_rows[[index]] <- tibble(panel = spec$panel, output = output_name)
  }

  audit <- bind_rows(plot_rows)
  readr::write_tsv(audit, file.path(opts$output_dir, "panel_plot_manifest.tsv"))
  invisible(audit)
}
