# Core R and Python utilities

`core/` contains functions shared by multiple workflows:

- `R/cli.R`: portable command-line arguments and run metadata;
- `R/analysis_helpers.R`: signatures, proportions, rank transforms and summaries;
- `R/figure_assembly.R`: panel input checks, light statistics and panel export;
- `R/plot_helpers.R`: common vector-plot theme and save settings;
- `python/common.py`: Python CLI, YAML, count validation and JSON run metadata;
- `python/spatial.py`: abundance-column cleaning, density scaling and pair burden.

All scripts accept `--config`, `--input-dir`, `--output-dir`, `--seed`
and `--threads`. Outputs are written below the supplied output directory; no
script changes the working directory or embeds a workstation/server path.

Third-party analyses are called from `workflows/`; package versions and the
parameters reported in the Methods are documented with the corresponding
workflow.
