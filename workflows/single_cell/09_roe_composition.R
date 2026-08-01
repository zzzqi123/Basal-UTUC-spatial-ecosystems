#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dplyr)
  library(MASS)
  library(readr)
  library(Seurat)
  library(tidyr)
})

source(file.path("core", "R", "cli.R"))
opts <- parse_common_args()
object <- readRDS(require_input(opts$input_dir, "utuc_annotated_scrna.rds"))
if (!inherits(object, "Seurat")) stop("Input must be a Seurat object")
metadata <- object[[]] %>%
  transmute(
    sample = orig.ident,
    group = Infil_group,
    cell_state = second_celltype_byhand
  ) %>%
  filter(!is.na(sample), !is.na(group), !is.na(cell_state))

sample_group <- metadata %>% distinct(sample, group)
if (anyDuplicated(sample_group$sample)) {
  stop("Each sample must map to exactly one composition group")
}
sample_counts <- tidyr::crossing(
  sample_group,
  cell_state = sort(unique(metadata$cell_state))
) %>%
  left_join(
    metadata %>% count(sample, group, cell_state, name = "observed"),
    by = c("sample", "group", "cell_state")
  ) %>%
  mutate(observed = replace_na(observed, 0L)) %>%
  group_by(sample) %>%
  mutate(total_cells = sum(observed)) %>%
  ungroup()

pooled <- sample_counts %>%
  group_by(group, cell_state) %>%
  summarise(observed = sum(observed), .groups = "drop")
grand_total <- sum(pooled$observed)
group_total <- pooled %>% group_by(group) %>% mutate(group_total = sum(observed))
state_total <- pooled %>% group_by(cell_state) %>% mutate(state_total = sum(observed))
roe <- pooled %>%
  left_join(distinct(group_total, group, group_total), by = "group") %>%
  left_join(distinct(state_total, cell_state, state_total), by = "cell_state") %>%
  mutate(
    expected = group_total * state_total / grand_total,
    roe = observed / expected
  )

nb_results <- lapply(split(sample_counts, sample_counts$cell_state), function(data) {
  data$group <- droplevels(factor(data$group))
  if (nlevels(data$group) < 2L || sum(data$observed) == 0) return(NULL)
  fit <- MASS::glm.nb(
    observed ~ group + offset(log(pmax(total_cells, 1))),
    data = data
  )
  coefficients <- summary(fit)$coefficients
  terms <- setdiff(rownames(coefficients), "(Intercept)")
  data.frame(
    cell_state = unique(data$cell_state),
    contrast = terms,
    log_rate_ratio = coefficients[terms, "Estimate"],
    rate_ratio = exp(coefficients[terms, "Estimate"]),
    standard_error = coefficients[terms, "Std. Error"],
    p_value = coefficients[terms, "Pr(>|z|)"]
  )
}) %>%
  bind_rows() %>%
  group_by(contrast) %>%
  mutate(fdr = p.adjust(p_value, method = "BH")) %>%
  ungroup()

dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
write_tsv(roe, file.path(opts$output_dir, "observed_expected_cell_composition.tsv"))
write_tsv(nb_results, file.path(opts$output_dir, "negative_binomial_group_effects.tsv"))
write_tsv(sample_counts, file.path(opts$output_dir, "sample_cellstate_counts.tsv"))
write_run_metadata(
  opts$output_dir,
  "single_cell_roe_composition",
  opts,
  list(
    roe = "pooled observed divided by independence expectation",
    inference = "sample-level negative-binomial model with log(total cells) offset"
  )
)
