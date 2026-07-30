#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(tidyr)
})

source(file.path("core", "R", "cli.R"))
source(file.path("core", "R", "analysis_helpers.R"))
opts <- parse_common_args()

scores <- read_tsv(
  require_input(opts$input_dir, "geomx_roi_signature_scores.tsv"),
  show_col_types = FALSE
)
program_manifest <- read_tsv(
  require_input(opts$input_dir, "geomx_program_columns.tsv"),
  show_col_types = FALSE
)
required <- c(
  "roi_id", "patient_id", "area_class", "treatment",
  "spp1_tam_score", "fap_mycaf_score"
)
if (length(setdiff(required, names(scores)))) {
  stop("GeoMx table is missing ROI metadata or component scores")
}
if (!"program" %in% names(program_manifest)) {
  stop("GeoMx program manifest requires a program column")
}
programs <- unique(program_manifest$program)
missing_programs <- setdiff(programs, names(scores))
if (length(missing_programs)) {
  stop("GeoMx score table is missing programs: ", paste(missing_programs, collapse = ", "))
}

scores <- scores %>%
  mutate(
    spp1_tam_z = safe_z(spp1_tam_score),
    fap_mycaf_z = safe_z(fap_mycaf_score),
    tam_mycaf_niche_score = spp1_tam_z + fap_mycaf_z
  )

correlations <- lapply(programs, function(program) {
  test <- cor.test(
    scores$tam_mycaf_niche_score,
    scores[[program]],
    method = "spearman",
    exact = FALSE
  )
  data.frame(
    program = program,
    rho = unname(test$estimate),
    p_value = test$p.value
  )
}) %>%
  bind_rows() %>%
  mutate(fdr = p.adjust(p_value, method = "BH"))

component_test <- cor.test(
  scores$spp1_tam_score,
  scores$fap_mycaf_score,
  method = "spearman",
  exact = FALSE
)
component_summary <- data.frame(
  comparison = "SPP1_TAM_vs_FAP_myCAF",
  rho = unname(component_test$estimate),
  p_value = component_test$p.value
)

dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
write_tsv(scores, file.path(opts$output_dir, "geomx_roi_niche_scores.tsv"))
write_tsv(correlations, file.path(opts$output_dir, "geomx_niche_program_correlations.tsv"))
write_tsv(component_summary, file.path(opts$output_dir, "geomx_component_correlation.tsv"))
write_run_metadata(
  opts$output_dir,
  "geomx_roi_tam_mycaf_validation",
  opts,
  list(
    score = "sum of z-scored SPP1+ TAM and FAP+ myCAF signatures",
    association = "ROI-level Spearman correlation"
  )
)
