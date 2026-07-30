suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(tidyr)
})

`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

rank_inverse_normal <- function(x) {
  ranks <- rank(as.numeric(x), ties.method = "average", na.last = "keep")
  n_observed <- sum(!is.na(ranks))
  if (!n_observed) return(rep(NA_real_, length(ranks)))
  qnorm((ranks - 0.5) / n_observed)
}

safe_z <- function(x) {
  values <- as.numeric(x)
  spread <- sd(values, na.rm = TRUE)
  if (!is.finite(spread) || spread == 0) {
    return(ifelse(is.na(values), NA_real_, 0))
  }
  as.numeric(scale(values))
}

cell_proportions <- function(metadata, group_col, celltype_col) {
  metadata %>%
    count(.data[[group_col]], .data[[celltype_col]], name = "n_cells") %>%
    group_by(.data[[group_col]]) %>%
    mutate(proportion = n_cells / sum(n_cells)) %>%
    ungroup()
}

signature_score <- function(expression, genes) {
  genes <- intersect(genes, rownames(expression))
  if (!length(genes)) stop("None of the signature genes are present")
  colMeans(expression[genes, , drop = FALSE], na.rm = TRUE)
}

pair_burden <- function(first, second, method = "geometric_mean") {
  first <- pmax(as.numeric(first), 0)
  second <- pmax(as.numeric(second), 0)
  if (method == "product") return(first * second)
  if (method == "geometric_mean") return(sqrt(first * second))
  stop("Unsupported pair burden method: ", method)
}

summarise_numeric_by_group <- function(data, groups) {
  numeric_names <- setdiff(
    names(data)[vapply(data, is.numeric, logical(1))],
    groups
  )
  if (!length(numeric_names)) {
    stop("No numeric columns remain after excluding grouping columns")
  }
  data %>%
    group_by(across(all_of(groups))) %>%
    summarise(
      across(
        all_of(numeric_names),
        list(mean = ~ mean(.x, na.rm = TRUE), median = ~ median(.x, na.rm = TRUE)),
        .names = "{.col}_{.fn}"
      ),
      n = n(),
      .groups = "drop"
    )
}
