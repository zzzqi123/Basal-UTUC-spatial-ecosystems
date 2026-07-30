#!/usr/bin/env Rscript

source(file.path("functions", "R", "cli.R"))
source(file.path("functions", "R", "figure_workflows.R"))
opts <- parse_common_args()
cfg <- read_module_config(opts$config)
set.seed(opts$seed)
output <- run_configured_analysis("SuppFig05", cfg, opts)
write_run_metadata(opts$output_dir, "SuppFig05_analysis", opts, list(output = output))
