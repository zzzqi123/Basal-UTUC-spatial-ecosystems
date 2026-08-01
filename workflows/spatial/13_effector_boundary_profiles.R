#!/usr/bin/env Rscript

# Construct the Fig. 6G three-compartment immune-effector profile:
# outer non-tumor side -> Niche1-high boundary -> adjacent tumor side.
# Boundary anchors are selected by Niche1 burden only, independently of the
# effector scores being evaluated.

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(tidyr)
  library(yaml)
})

source(file.path("core", "R", "cli.R"))
opts <- parse_common_args()
cfg <- yaml::read_yaml(opts$config)$effector_boundary
set.seed(opts$seed)

spots <- read_tsv(
  require_input(opts$input_dir, "niche1_boundary_spots.tsv"),
  show_col_types = FALSE
)
edges <- read_tsv(
  require_input(opts$input_dir, "visium_ring1_edges.tsv"),
  show_col_types = FALSE
)
programs <- cfg$program_columns
required_spots <- c(
  "spot_id", "sample", "compartment", "niche1_burden", programs
)
required_edges <- c("sample", "spot_id", "neighbor_id", "ring")
missing_spots <- setdiff(required_spots, names(spots))
missing_edges <- setdiff(required_edges, names(edges))
if (length(missing_spots) || length(missing_edges)) {
  stop(
    "Boundary input schema mismatch; spot columns missing: ",
    paste(missing_spots, collapse = ", "),
    "; edge columns missing: ", paste(missing_edges, collapse = ", ")
  )
}
if (anyDuplicated(spots[c("sample", "spot_id")])) {
  stop("spot_id must be unique within each section")
}

allowed_compartments <- c("outer_non_tumor", "niche1_boundary", "tumor_side")
if (any(!spots$compartment %in% allowed_compartments)) {
  stop("compartment must be outer_non_tumor, niche1_boundary or tumor_side")
}

program_long <- spots %>%
  group_by(sample) %>%
  mutate(across(
    all_of(programs),
    ~ if (sd(.x, na.rm = TRUE) > 0) as.numeric(scale(.x)) else 0,
    .names = "{.col}_z"
  )) %>%
  ungroup() %>%
  select(sample, spot_id, compartment, niche1_burden, ends_with("_z")) %>%
  pivot_longer(
    cols = ends_with("_z"),
    names_to = "program",
    values_to = "score"
  ) %>%
  mutate(program = sub("_z$", "", program))

anchors <- spots %>%
  filter(compartment == "niche1_boundary") %>%
  group_by(sample) %>%
  mutate(cutoff = quantile(
    niche1_burden,
    probs = cfg$niche1_boundary_quantile,
    na.rm = TRUE
  )) %>%
  filter(niche1_burden >= cutoff) %>%
  ungroup() %>%
  transmute(sample, anchor_spot_id = spot_id, niche1_burden, cutoff)
if (!nrow(anchors)) stop("No Niche1-high boundary anchors were selected")

ring_edges <- edges %>%
  filter(ring == cfg$neighbor_ring) %>%
  inner_join(anchors, by = c("sample", "spot_id" = "anchor_spot_id")) %>%
  rename(anchor_spot_id = spot_id)

neighbor_values <- ring_edges %>%
  inner_join(
    program_long %>%
      select(sample, neighbor_id = spot_id, compartment, program, score),
    by = c("sample", "neighbor_id")
  ) %>%
  filter(compartment %in% c("outer_non_tumor", "tumor_side")) %>%
  group_by(sample, anchor_spot_id, niche1_burden, cutoff, compartment, program) %>%
  summarise(score = mean(score, na.rm = TRUE), n_neighbors = n(), .groups = "drop")

boundary_values <- anchors %>%
  inner_join(
    program_long %>%
      filter(compartment == "niche1_boundary") %>%
      select(sample, anchor_spot_id = spot_id, program, score),
    by = c("sample", "anchor_spot_id")
  ) %>%
  mutate(compartment = "niche1_boundary", n_neighbors = 1L)

triplets <- bind_rows(neighbor_values, boundary_values) %>%
  select(
    sample, anchor_spot_id, program, compartment, score,
    niche1_burden, cutoff, n_neighbors
  ) %>%
  group_by(sample, anchor_spot_id, program) %>%
  filter(n_distinct(compartment) == 3L) %>%
  ungroup()
if (!nrow(triplets)) {
  stop("No boundary anchor had exact-ring neighbors in both outer and tumor compartments")
}

position_map <- c(
  outer_non_tumor = 1,
  niche1_boundary = 2,
  tumor_side = 3
)
profiles <- triplets %>%
  mutate(
    boundary_position = unname(position_map[compartment]),
    position_label = recode(
      compartment,
      outer_non_tumor = "Outer non-tumor side",
      niche1_boundary = "Niche1-high boundary",
      tumor_side = "Adjacent tumor side"
    )
  ) %>%
  group_by(sample, program, boundary_position, position_label) %>%
  summarise(
    mean_score = mean(score, na.rm = TRUE),
    n_anchors = n_distinct(anchor_spot_id),
    .groups = "drop"
  )

dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
write_tsv(triplets, file.path(opts$output_dir, "effector_boundary_triplets.tsv"))
write_tsv(profiles, file.path(opts$output_dir, "effector_boundary_profiles.tsv"))
write_run_metadata(
  opts$output_dir,
  "niche1_effector_boundary_profiles",
  opts,
  list(
    anchor_selection = paste0(
      "top ", 100 * (1 - cfg$niche1_boundary_quantile),
      "% Niche1 burden within the boundary compartment"
    ),
    neighbor_ring = cfg$neighbor_ring,
    standardization = "within-section z score",
    programs = programs
  )
)
