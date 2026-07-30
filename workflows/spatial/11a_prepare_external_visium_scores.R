#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(Seurat)
  library(UCell)
  library(yaml)
})

source(file.path("core", "R", "cli.R"))
opts <- parse_common_args()
config <- yaml::read_yaml(opts$config)
cfg <- config$external_spatial_validation
rctd_cfg <- config$rctd
set.seed(opts$seed)

sections <- readRDS(require_input(opts$input_dir, "external_visium_sections.rds"))
weights <- read_tsv(
  require_input(opts$input_dir, "external_visium_rctd_proportions.tsv.gz"),
  show_col_types = FALSE
)
if (!is.list(sections) || !length(sections)) {
  stop("external_visium_sections.rds must contain a named list of Seurat objects")
}
required_weights <- c(
  "section", "spot_id", "Epithelial", "SPP1_TAM", "FAP_myCAF"
)
if (length(setdiff(required_weights, names(weights)))) {
  stop("RCTD table requires section, spot_id and named proportion columns")
}

hex_offsets <- list(
  ring0 = matrix(c(0, 0), ncol = 2),
  ring1 = matrix(
    c(0, 2, 0, -2, 1, 1, 1, -1, -1, 1, -1, -1),
    byrow = TRUE,
    ncol = 2
  )
)
ring2_candidates <- do.call(
  rbind,
  lapply(seq_len(nrow(hex_offsets$ring1)), function(i) {
    sweep(hex_offsets$ring1, 2, hex_offsets$ring1[i, ], "+")
  })
)
lower_rings <- rbind(hex_offsets$ring0, hex_offsets$ring1)
is_lower_ring <- apply(ring2_candidates, 1, function(candidate) {
  any(apply(lower_rings, 1, function(existing) all(candidate == existing)))
})
hex_offsets$ring2 <- unique(ring2_candidates[!is_lower_ring, , drop = FALSE])

ring_mean <- function(values, rows, columns, offsets) {
  keys <- paste(rows, columns, sep = ":")
  value_map <- setNames(values, keys)
  vapply(seq_along(values), function(index) {
    neighbor_keys <- paste(
      rows[index] + offsets[, 1],
      columns[index] + offsets[, 2],
      sep = ":"
    )
    candidates <- unname(value_map[neighbor_keys])
    if (!any(is.finite(candidates))) return(NA_real_)
    mean(candidates, na.rm = TRUE)
  }, numeric(1))
}

score_section <- function(object, section_id) {
  if (!inherits(object, "Seurat")) stop(section_id, " is not a Seurat object")
  DefaultAssay(object) <- "Spatial"
  object <- NormalizeData(object, assay = "Spatial", verbose = FALSE)
  object <- AddModuleScore_UCell(
    object,
    features = list(Basal = cfg$basal_genes, Luminal = cfg$luminal_genes),
    assay = "Spatial"
  )
  metadata <- object[[]]
  metadata$spot_id <- rownames(metadata)
  section_weights <- weights %>% filter(section == section_id)
  data <- inner_join(metadata, section_weights, by = "spot_id")
  if (!all(c("array_row", "array_col") %in% names(data))) {
    stop(section_id, " requires array_row and array_col metadata")
  }
  weight_columns <- names(section_weights)[
    vapply(section_weights, is.numeric, logical(1))
  ]
  weight_columns <- setdiff(
    weight_columns,
    c("x", "y", "array_row", "array_col")
  )
  if (!all(c("Epithelial", "SPP1_TAM", "FAP_myCAF") %in% weight_columns)) {
    stop(section_id, " is missing required RCTD cell-type weights")
  }
  data$dominant_celltype <- apply(
    data[, weight_columns, drop = FALSE],
    1,
    function(x) weight_columns[[which.max(x)]]
  )
  data <- data %>%
    mutate(
      section = section_id,
      epithelial_proportion = Epithelial,
      basal_score = Basal_UCell,
      luminal_score = Luminal_UCell
    )
  bind_rows(lapply(names(hex_offsets), function(ring_name) {
    offsets <- hex_offsets[[ring_name]]
    data %>%
      transmute(
        section,
        spot_id,
        array_row,
        array_col,
        dominant_celltype,
        epithelial_proportion,
        basal_score,
        luminal_score,
        spp1_tam_proportion = ring_mean(
          SPP1_TAM,
          array_row,
          array_col,
          offsets
        ),
        fap_mycaf_proportion = ring_mean(
          FAP_myCAF,
          array_row,
          array_col,
          offsets
        ),
        ring = ring_name
      )
  }))
}

section_ids <- names(sections)
if (is.null(section_ids) || any(!nzchar(section_ids))) {
  stop("External section list must be named")
}
if (
  !is.null(cfg$expected_sections) &&
  length(section_ids) != cfg$expected_sections
) {
  stop(
    "Expected ", cfg$expected_sections,
    " external Visium sections but received ", length(section_ids)
  )
}
spot_scores <- bind_rows(Map(score_section, sections, section_ids))

dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
write_tsv(
  spot_scores,
  file.path(opts$output_dir, "external_visium_spot_scores.tsv.gz")
)
write_run_metadata(
  opts$output_dir,
  "prepare_external_visium_rctd_ucell_scores",
  opts,
  list(
    sections = length(sections),
    rctd_mode = rctd_cfg$gse319536_mode,
    epithelial_anchor_fraction = rctd_cfg$epithelial_anchor_fraction,
    neighborhood_rings = names(hex_offsets)
  )
)
