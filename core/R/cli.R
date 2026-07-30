suppressPackageStartupMessages(library(yaml))

parse_common_args <- function(args = commandArgs(trailingOnly = TRUE)) {
  defaults <- list(
    config = NULL,
    input_dir = NULL,
    output_dir = NULL,
    seed = 20260730L,
    threads = 1L
  )
  i <- 1L
  while (i <= length(args)) {
    key <- sub("^--", "", args[[i]])
    if (!key %in% c("config", "input-dir", "output-dir", "seed", "threads")) {
      stop("Unknown argument: ", args[[i]])
    }
    if (i == length(args)) stop("Missing value for ", args[[i]])
    value <- args[[i + 1L]]
    key <- gsub("-", "_", key)
    defaults[[key]] <- value
    i <- i + 2L
  }
  required <- c("config", "input_dir", "output_dir")
  missing <- required[vapply(defaults[required], is.null, logical(1))]
  if (length(missing)) stop("Missing arguments: ", paste(missing, collapse = ", "))
  defaults$seed <- as.integer(defaults$seed)
  defaults$threads <- as.integer(defaults$threads)
  defaults
}

read_module_config <- function(path) {
  if (!file.exists(path)) stop("Config not found: ", path)
  cfg <- yaml::read_yaml(path)
  if (!is.list(cfg)) stop("Config must be a YAML mapping: ", path)
  cfg
}

require_input <- function(input_dir, relative_path, label = relative_path) {
  path <- file.path(input_dir, relative_path)
  if (!file.exists(path)) stop("Missing ", label, ": ", path)
  path
}

write_run_metadata <- function(output_dir, workflow, opts, extra = list()) {
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  git_commit <- tryCatch(
    system2("git", c("rev-parse", "--short=12", "HEAD"), stdout = TRUE),
    error = function(e) NA_character_
  )
  if (!length(git_commit)) git_commit <- NA_character_
  metadata <- c(
    list(
      workflow = workflow,
      config = opts$config,
      seed = opts$seed,
      threads = opts$threads,
      run_time_utc = format(Sys.time(), tz = "UTC", usetz = TRUE),
      git_commit = git_commit[[1]],
      r_version = R.version.string
    ),
    extra
  )
  yaml::write_yaml(metadata, file.path(output_dir, "run_metadata.yaml"))
}
