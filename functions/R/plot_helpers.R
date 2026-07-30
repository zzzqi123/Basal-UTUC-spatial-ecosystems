suppressPackageStartupMessages({
  library(ggplot2)
  library(readr)
})

publication_theme <- function(base_size = 9) {
  theme_classic(base_size = base_size, base_family = "Arial") +
    theme(
      plot.title = element_text(face = "bold", hjust = 0),
      axis.title = element_text(face = "bold"),
      legend.title = element_blank(),
      strip.background = element_blank(),
      strip.text = element_text(face = "bold")
    )
}

save_vector_plot <- function(plot, path, width = 6, height = 4) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  ggsave(path, plot, width = width, height = height, device = cairo_pdf)
}

plot_group_summary <- function(data, x, y, color = NULL, title = NULL) {
  mapping <- aes(x = .data[[x]], y = .data[[y]])
  if (!is.null(color)) mapping$colour <- rlang::expr(.data[[!!color]])
  ggplot(data, mapping) +
    geom_boxplot(outlier.shape = NA, width = 0.65) +
    geom_jitter(width = 0.12, alpha = 0.55, size = 1) +
    labs(title = title, x = NULL, y = y) +
    publication_theme()
}

