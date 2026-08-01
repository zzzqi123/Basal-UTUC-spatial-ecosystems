#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
})

file_arg <- commandArgs(FALSE)[grep("^--file=", commandArgs(FALSE))]
file_arg <- sub("^--file=", "", file_arg)
root <- normalizePath(file.path(dirname(file_arg), ".."))
setwd(root)

test_dir <- tempfile("utuc-fig10-synthetic-")
input_dir <- file.path(test_dir, "input")
output_dir <- file.path(test_dir, "output")
dir.create(input_dir, recursive = TRUE)
on.exit(unlink(test_dir, recursive = TRUE, force = TRUE), add = TRUE)

multiscale <- expand.grid(
  section = c("section_01", "section_02"),
  program = c("Niche1", "Niche2"),
  ring = 0:2,
  stringsAsFactors = FALSE
) %>%
  mutate(
    pair_burden = seq_len(n()) / 10,
    fold_vs_nmi = 0.8 + seq_len(n()) / 20,
    spatial_oe = 0.9 + seq_len(n()) / 25,
    permutation_p_upper = 0.01 + seq_len(n()) / 1000
  )
write_tsv(
  multiscale,
  file.path(input_dir, "multiscale_pair_burden_and_oe.tsv")
)

boundary <- expand.grid(
  sample = c("section_01", "section_02"),
  cell_state = c("Macro_c0_SPP1", "CAF_c3_POSTN"),
  signed_distance = -2:2,
  stringsAsFactors = FALSE
) %>%
  mutate(
    fitted_z = tanh(signed_distance / 2),
    se = 0.1
  )
write_tsv(boundary, file.path(input_dir, "section_boundary_predictions.tsv"))

external <- expand.grid(
  basal_axis_percentile = c(0.1, 0.5, 0.9),
  ring = c("ring0", "ring1", "ring2"),
  stringsAsFactors = FALSE
) %>%
  mutate(
    mean_curve = basal_axis_percentile + as.numeric(factor(ring)) / 10,
    ci_low = mean_curve - 0.1,
    ci_high = mean_curve + 0.1
  )
write_tsv(
  external,
  file.path(input_dir, "external_visium_mean_gam_curves.tsv")
)

clinical <- expand.grid(
  score = c("myeloid_stromal_program", "angiogenic_program", "cancer_c3"),
  endpoint = c("Muscle invasion", "Disease-specific survival"),
  stringsAsFactors = FALSE
) %>%
  mutate(
    model = if_else(
      endpoint == "Muscle invasion",
      "Age/sex-adjusted",
      "Age/sex/MI-adjusted"
    ),
    effect = 1 + seq_len(n()) / 20,
    CI_low = effect - 0.1,
    CI_high = effect + 0.1,
    p_value = 0.01 * seq_len(n()),
    FDR_BH = p.adjust(p_value, method = "BH")
  )
write_tsv(clinical, file.path(input_dir, "japan_utuc_clinical_models.tsv"))

run_script <- function(script, input_path, output_path) {
  output <- system2(
    "Rscript",
    c(
      script,
      "--config", "figures/Fig10/config.yaml",
      "--input-dir", input_path,
      "--output-dir", output_path,
      "--seed", "20260730",
      "--threads", "1"
    ),
    stdout = TRUE,
    stderr = TRUE
  )
  status <- attr(output, "status")
  if (!is.null(status) && status != 0L) {
    stop(paste(output, collapse = "\n"))
  }
}

run_script("figures/Fig10/01_analysis.R", input_dir, output_dir)
run_script("figures/Fig10/02_plot.R", output_dir, output_dir)

expected <- readLines("figures/Fig10/expected_outputs.txt")
paths <- file.path(output_dir, expected[nzchar(expected)])
stopifnot(all(file.exists(paths)), all(file.info(paths)$size > 0))

message("PASS: Fig. 10 synthetic table-to-PDF assembly test")
