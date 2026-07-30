#!/usr/bin/env Rscript

source(file.path("functions", "R", "cli.R"))
source(file.path("functions", "R", "figure_workflows.R"))
opts <- parse_common_args()
cfg <- read_module_config(opts$config)
run_configured_plot("Fig06", cfg, opts)
write_run_metadata(opts$output_dir, "Fig06_plot", opts)
