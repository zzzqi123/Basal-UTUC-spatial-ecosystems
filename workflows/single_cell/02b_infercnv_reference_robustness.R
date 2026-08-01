#!/usr/bin/env Rscript

# Compare the manuscript-primary adjacent-epithelial inferCNV analysis with
# the within-sample non-epithelial-reference sensitivity analysis. All CNV
# comparisons use exactly matched epithelial cells and common genes.

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(tidyr)
  library(yaml)
})

source(file.path("core", "R", "cli.R"))
opts <- parse_common_args()
set.seed(opts$seed)

read_cnv_matrix <- function(path) {
  table <- read_tsv(path, show_col_types = FALSE)
  if (ncol(table) < 3L) {
    stop("CNV matrix requires gene_id plus at least two cell columns: ", path)
  }
  gene_id <- as.character(table[[1]])
  if (anyDuplicated(gene_id)) stop("Duplicated genes in ", path)
  matrix <- as.matrix(table[, -1, drop = FALSE])
  storage.mode(matrix) <- "double"
  rownames(matrix) <- gene_id
  matrix
}

safe_spearman <- function(x, y) {
  keep <- is.finite(x) & is.finite(y)
  if (sum(keep) < 3L || sd(x[keep]) == 0 || sd(y[keep]) == 0) return(NA_real_)
  cor(x[keep], y[keep], method = "spearman")
}

primary <- read_cnv_matrix(require_input(
  opts$input_dir,
  "infercnv_primary_matched_matrix.tsv.gz"
))
sensitivity <- read_cnv_matrix(require_input(
  opts$input_dir,
  "infercnv_sensitivity_matched_matrix.tsv.gz"
))
metadata <- read_tsv(
  require_input(opts$input_dir, "infercnv_cell_metadata.tsv"),
  show_col_types = FALSE
)
assignments <- read_tsv(
  require_input(opts$input_dir, "malignant_reference_assignments.tsv"),
  show_col_types = FALSE
)
marker_profiles <- read_tsv(
  require_input(opts$input_dir, "malignant_marker_profiles.tsv"),
  show_col_types = FALSE
)
hallmark <- read_tsv(
  require_input(opts$input_dir, "malignant_hallmark_nes.tsv"),
  show_col_types = FALSE
)

required_metadata <- c("cell_id", "sample")
required_assignments <- c(
  "cell_id", "UMAP_1", "UMAP_2", "primary_malignant",
  "sensitivity_malignant", "primary_cluster", "sensitivity_cluster"
)
required_markers <- c("analysis", "cluster", "gene", "average_expression")
required_hallmark <- c("analysis", "cell_state", "pathway", "NES")
checks <- list(
  metadata = setdiff(required_metadata, names(metadata)),
  assignments = setdiff(required_assignments, names(assignments)),
  marker_profiles = setdiff(required_markers, names(marker_profiles)),
  hallmark = setdiff(required_hallmark, names(hallmark))
)
bad <- names(checks)[lengths(checks) > 0L]
if (length(bad)) {
  stop(paste(vapply(
    bad,
    function(x) paste0(x, " missing: ", paste(checks[[x]], collapse = ", ")),
    character(1)
  ), collapse = "; "))
}
if (anyDuplicated(metadata$cell_id) || anyDuplicated(assignments$cell_id)) {
  stop("Cell identifiers must be unique in metadata and assignments")
}

common_genes <- intersect(rownames(primary), rownames(sensitivity))
common_cells <- Reduce(
  intersect,
  list(colnames(primary), colnames(sensitivity), metadata$cell_id)
)
if (length(common_genes) < 100L || length(common_cells) < 20L) {
  stop("Insufficient matched cells or common genes for inferCNV comparison")
}
primary <- primary[common_genes, common_cells, drop = FALSE]
sensitivity <- sensitivity[common_genes, common_cells, drop = FALSE]

# inferCNV is centered at one; mean squared deviation gives a scale-compatible
# CNV burden before within-sample percentile ranking.
cell_scores <- tibble(
  cell_id = common_cells,
  primary_score = colMeans((primary - 1) ^ 2, na.rm = TRUE),
  sensitivity_score = colMeans((sensitivity - 1) ^ 2, na.rm = TRUE)
) %>%
  left_join(metadata %>% select(all_of(required_metadata)), by = "cell_id") %>%
  group_by(sample) %>%
  mutate(
    primary_percentile = (rank(primary_score, ties.method = "average") - 0.5) / n(),
    sensitivity_percentile =
      (rank(sensitivity_score, ties.method = "average") - 0.5) / n()
  ) %>%
  ungroup()

patient_correlations <- cell_scores %>%
  group_by(sample) %>%
  summarise(
    n_cells = n(),
    spearman_rho = safe_spearman(primary_score, sensitivity_score),
    .groups = "drop"
  )

assignment_long <- assignments %>%
  filter(cell_id %in% common_cells) %>%
  select(cell_id, UMAP_1, UMAP_2, primary_cluster, sensitivity_cluster) %>%
  pivot_longer(
    cols = c(primary_cluster, sensitivity_cluster),
    names_to = "analysis",
    values_to = "cell_state"
  ) %>%
  mutate(
    analysis = recode(
      analysis,
      primary_cluster = "primary_adjacent_epithelial_reference",
      sensitivity_cluster = "sensitivity_non_epithelial_reference"
    )
  )

malignant_overlap <- assignments %>%
  filter(cell_id %in% common_cells) %>%
  count(primary_malignant, sensitivity_malignant, name = "count")

primary_markers <- marker_profiles %>%
  filter(analysis == "primary") %>%
  transmute(
    primary_cluster = cluster,
    gene,
    primary_expression = average_expression
  )
sensitivity_markers <- marker_profiles %>%
  filter(analysis == "sensitivity") %>%
  transmute(
    sensitivity_cluster = cluster,
    gene,
    sensitivity_expression = average_expression
  )
marker_concordance <- inner_join(primary_markers, sensitivity_markers, by = "gene") %>%
  group_by(primary_cluster, sensitivity_cluster) %>%
  summarise(
    n_genes = n(),
    spearman_rho = safe_spearman(primary_expression, sensitivity_expression),
    .groups = "drop"
  )

hallmark_concordance <- hallmark %>%
  filter(cell_state %in% c("Cancer_c0", "Cancer_c3")) %>%
  select(analysis, cell_state, pathway, NES) %>%
  distinct() %>%
  pivot_wider(names_from = analysis, values_from = NES, names_glue = "{analysis}_NES")
required_nes <- c("primary_NES", "sensitivity_NES")
if (length(setdiff(required_nes, names(hallmark_concordance)))) {
  stop("Hallmark table must use analysis values 'primary' and 'sensitivity'")
}

dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
write_tsv(cell_scores, file.path(opts$output_dir, "panel_C_cnv_burden_ranks.tsv"))
write_tsv(
  patient_correlations,
  file.path(opts$output_dir, "panel_D_patient_rank_correlations.tsv")
)
write_tsv(
  assignment_long,
  file.path(opts$output_dir, "panel_E_malignant_subcluster_umap.tsv")
)
write_tsv(
  malignant_overlap,
  file.path(opts$output_dir, "panel_F_malignant_overlap.tsv")
)
write_tsv(
  marker_concordance,
  file.path(opts$output_dir, "panel_G_marker_profile_concordance.tsv")
)
write_tsv(
  hallmark_concordance,
  file.path(opts$output_dir, "panel_H_hallmark_nes_concordance.tsv")
)
write_run_metadata(
  opts$output_dir,
  "infercnv_reference_robustness",
  opts,
  list(
    primary_reference = "adjacent epithelial cells",
    sensitivity_reference = "within-sample immune, stromal and endothelial cells",
    matched_cells = length(common_cells),
    common_genes = length(common_genes),
    score = "mean squared deviation from inferCNV neutral value 1",
    comparison = "within-sample percentile ranks"
  )
)
