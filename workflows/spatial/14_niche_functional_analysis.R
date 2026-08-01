#!/usr/bin/env Rscript

# Functional characterization of the two spatial niches in Supplementary
# Fig. S14. Panel B uses one integrated ranked gene list per niche. Panel C
# models both niche burdens jointly in each MI section and combines section
# estimates by fixed-effect meta-analysis.

suppressPackageStartupMessages({
  library(clusterProfiler)
  library(dplyr)
  library(readr)
  library(sandwich)
  library(tidyr)
  library(yaml)
})

source(file.path("core", "R", "cli.R"))
opts <- parse_common_args()
cfg <- yaml::read_yaml(opts$config)$niche_function
set.seed(opts$seed)

z_score <- function(x) {
  x <- as.numeric(x)
  if (sd(x, na.rm = TRUE) == 0) return(rep(0, length(x)))
  as.numeric(scale(x))
}

effects <- read_tsv(
  require_input(opts$input_dir, "niche_component_gene_effects.tsv"),
  show_col_types = FALSE
)
term2gene <- read_tsv(
  require_input(opts$input_dir, "pathway_gene_sets.tsv"),
  show_col_types = FALSE
)
spots <- read_tsv(
  require_input(opts$input_dir, "spatial_niche_pathway_scores.tsv"),
  show_col_types = FALSE
)

required_effects <- c("niche", "component", "gene", "effect")
required_sets <- c("pathway", "gene")
required_spots <- c(
  "sample", "spatial_block", "pathway", "pathway_score",
  "niche_1_burden", "niche_2_burden", "library_size",
  "total_abundance", "malignant_fraction"
)
for (check in list(
  effects = setdiff(required_effects, names(effects)),
  term2gene = setdiff(required_sets, names(term2gene)),
  spots = setdiff(required_spots, names(spots))
)) {
  if (length(check)) stop("Functional-analysis input missing: ", paste(check, collapse = ", "))
}

effects <- effects %>%
  filter(!gene %in% cfg$excluded_marker_genes) %>%
  group_by(niche, component) %>%
  mutate(
    component_percentile =
      rank(effect, ties.method = "average") / (n() + 1) - 0.5
  ) %>%
  ungroup()

expected_components <- effects %>%
  distinct(niche, component) %>%
  count(niche, name = "expected_components")
integrated_ranks <- effects %>%
  group_by(niche, gene) %>%
  summarise(
    integrated_rank = mean(component_percentile),
    observed_components = n_distinct(component),
    .groups = "drop"
  ) %>%
  left_join(expected_components, by = "niche") %>%
  filter(observed_components == expected_components) %>%
  arrange(niche, desc(integrated_rank), gene)

run_niche_gsea <- function(niche_name) {
  table <- integrated_ranks %>% filter(niche == niche_name)
  ranks <- table$integrated_rank
  names(ranks) <- table$gene
  ranks <- sort(ranks, decreasing = TRUE)
  # Deterministic, negligible tie breaker required by ranked-list algorithms.
  ranks <- ranks + rev(seq_along(ranks)) * .Machine$double.eps
  object <- clusterProfiler::GSEA(
    geneList = ranks,
    TERM2GENE = term2gene %>% select(pathway, gene),
    minGSSize = cfg$min_gene_set_size,
    maxGSSize = cfg$max_gene_set_size,
    pvalueCutoff = 1,
    pAdjustMethod = "BH",
    eps = 0,
    by = "fgsea",
    verbose = FALSE
  )
  as.data.frame(object) %>%
    as_tibble() %>%
    transmute(
      niche = niche_name,
      pathway = ID,
      NES,
      p_value = pvalue,
      FDR = p.adjust,
      core_enrichment
    )
}
gsea <- bind_rows(lapply(unique(integrated_ranks$niche), run_niche_gsea))

included_sections <- unlist(cfg$included_sections, use.names = FALSE)
spots <- spots %>% filter(sample %in% included_sections)
if (!nrow(spots)) stop("No configured MI sections were present in spatial scores")
pathway_plan <- bind_rows(lapply(names(cfg$spatial_pathway_plan), function(niche) {
  tibble(
    niche,
    pathway = unlist(cfg$spatial_pathway_plan[[niche]], use.names = FALSE)
  )
}))

fit_one <- function(table) {
  table <- table %>%
    mutate(
      pathway_score_z = z_score(pathway_score),
      niche_1_z = z_score(log1p(pmax(niche_1_burden, 0))),
      niche_2_z = z_score(log1p(pmax(niche_2_burden, 0))),
      library_size_z = z_score(log1p(pmax(library_size, 0))),
      total_abundance_z = z_score(log1p(pmax(total_abundance, 0))),
      malignant_fraction_z = z_score(malignant_fraction)
    )
  fit <- lm(
    pathway_score_z ~ niche_1_z + niche_2_z + library_size_z +
      total_abundance_z + malignant_fraction_z,
    data = table
  )
  vcov <- sandwich::vcovCL(fit, cluster = table$spatial_block, type = "HC1")
  bind_rows(lapply(c("niche_1_z", "niche_2_z"), function(term) {
    beta <- unname(coef(fit)[term])
    se <- sqrt(unname(vcov[term, term]))
    tibble(
      niche = recode(term, niche_1_z = "Niche1", niche_2_z = "Niche2"),
      beta,
      se,
      CI_low = beta - 1.96 * se,
      CI_high = beta + 1.96 * se,
      n_spots = nrow(table),
      n_spatial_blocks = n_distinct(table$spatial_block)
    )
  }))
}

section_associations <- spots %>%
  group_by(sample, pathway) %>%
  group_modify(~ fit_one(.x)) %>%
  ungroup() %>%
  inner_join(pathway_plan, by = c("niche", "pathway"))

meta_associations <- section_associations %>%
  group_by(niche, pathway) %>%
  summarise(
    min_section_beta = min(beta),
    max_section_beta = max(beta),
    direction_consistent = all(beta > 0) || all(beta < 0),
    estimate = weighted.mean(beta, w = 1 / pmax(se ^ 2, 1e-12)),
    meta_se = sqrt(1 / sum(1 / pmax(se ^ 2, 1e-12))),
    .groups = "drop"
  ) %>%
  mutate(
    beta = estimate,
    se = meta_se,
    CI_low = beta - 1.96 * se,
    CI_high = beta + 1.96 * se,
    p_value = 2 * pnorm(-abs(beta / se)),
    FDR = p.adjust(p_value, method = "BH")
  ) %>%
  select(-estimate, -meta_se)
displayed_associations <- inner_join(
  pathway_plan,
  meta_associations,
  by = c("niche", "pathway")
)
if (nrow(displayed_associations) != nrow(pathway_plan)) {
  stop("One or more prespecified niche-pathway pairs were not modeled")
}

dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
write_tsv(
  integrated_ranks,
  file.path(opts$output_dir, "panel_B_integrated_niche_gene_ranks.tsv")
)
write_tsv(gsea, file.path(opts$output_dir, "panel_B_hallmark_gsea.tsv"))
write_tsv(
  section_associations,
  file.path(opts$output_dir, "panel_C_section_spatial_associations.tsv")
)
write_tsv(
  displayed_associations,
  file.path(opts$output_dir, "panel_C_meta_spatial_associations.tsv")
)
write_run_metadata(
  opts$output_dir,
  "spatial_niche_functional_analysis",
  opts,
  list(
    included_sections = included_sections,
    gsea_integration = "mean centered within-component percentile",
    spatial_model = paste(
      "pathway ~ Niche1 + Niche2 + library size + total abundance +",
      "malignant fraction; cluster-robust SE by spatial block"
    ),
    meta_analysis = "fixed effect inverse variance"
  )
)
