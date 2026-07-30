#!/usr/bin/env Rscript

source(file.path("functions", "R", "cli.R"))
source(file.path("functions", "R", "figure_workflows.R"))
opts <- parse_common_args()
cfg <- read_module_config(opts$config)
run_configured_plot("SuppFig13", cfg, opts)
write_run_metadata(opts$output_dir, "SuppFig13_plot", opts)
