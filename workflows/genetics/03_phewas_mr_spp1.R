#!/usr/bin/env Rscript

# Post-processes normalized SMR/HEIDI output for the manuscript PheW-MR
# analysis. Instrument construction and SMR execution remain upstream official
# software steps; their result schema is validated here.

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(yaml)
})

source(file.path("core", "R", "cli.R"))
opts <- parse_common_args()
cfg <- yaml::read_yaml(opts$config)$phewas_mr
if (is.null(cfg)) stop("Config requires a phewas_mr section")

results <- read_tsv(
  require_input(opts$input_dir, "spp1_phewas_smr_results.tsv.gz"),
  show_col_types = FALSE
)
required <- c(
  "phenotype_id", "phenotype", "category", "n_cases",
  "beta_smr", "se_smr", "p_smr", "p_heidi"
)
missing <- setdiff(required, names(results))
if (length(missing)) {
  stop("SMR result table is missing: ", paste(missing, collapse = ", "))
}
if (anyDuplicated(results$phenotype_id)) {
  stop("Each binary phenotype must appear once in the normalized SMR table")
}
if (nrow(results) != cfg$total_binary_phenotypes) {
  stop(
    "Expected ", cfg$total_binary_phenotypes,
    " binary phenotypes before case-count filtering; observed ", nrow(results)
  )
}

eligible <- results %>%
  filter(n_cases > cfg$min_cases_exclusive) %>%
  mutate(
    smr_fdr = p.adjust(p_smr, method = cfg$multiple_testing),
    heidi_pass = is.finite(p_heidi) & p_heidi > cfg$heidi_p_threshold,
    significant = heidi_pass & smr_fdr < cfg$fdr_threshold,
    odds_ratio = exp(beta_smr),
    ci_low = exp(beta_smr - 1.96 * se_smr),
    ci_high = exp(beta_smr + 1.96 * se_smr)
  ) %>%
  arrange(smr_fdr, desc(p_heidi))

if (nrow(eligible) != cfg$expected_eligible_phenotypes) {
  stop(
    "Expected ", cfg$expected_eligible_phenotypes,
    " phenotypes with > ", cfg$min_cases_exclusive,
    " cases; observed ", nrow(eligible)
  )
}

summary <- eligible %>%
  summarise(
    target_gene = cfg$target_gene,
    outcome_source = cfg$outcome_source,
    outcome_sample_size = cfg$outcome_sample_size,
    tested_phenotypes = n(),
    heidi_pass = sum(heidi_pass),
    fdr_significant_and_heidi_pass = sum(significant)
  )

dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
write_tsv(eligible, file.path(opts$output_dir, "spp1_phewas_smr_eligible.tsv.gz"))
write_tsv(
  filter(eligible, significant),
  file.path(opts$output_dir, "spp1_phewas_smr_significant.tsv")
)
write_tsv(summary, file.path(opts$output_dir, "spp1_phewas_smr_summary.tsv"))
write_run_metadata(
  opts$output_dir,
  "spp1_phewas_mr",
  opts,
  list(
    method = "SMR with HEIDI exclusion",
    min_cases_exclusive = cfg$min_cases_exclusive,
    heidi_p_threshold = cfg$heidi_p_threshold,
    fdr_method = cfg$multiple_testing,
    fdr_threshold = cfg$fdr_threshold
  )
)
