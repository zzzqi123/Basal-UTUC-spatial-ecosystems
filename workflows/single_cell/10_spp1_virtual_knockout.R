#!/usr/bin/env Rscript

# SPP1 virtual knockout in UTUC malignant epithelial cells (Cancer_c0-c4).
# Whole-TME and FAP knockout experiments are not part of this analysis.

suppressPackageStartupMessages({
  library(clusterProfiler)
  library(org.Hs.eg.db)
  library(scTenifoldKnk)
  library(Seurat)
})

source(file.path("core", "R", "cli.R"))
opts <- parse_common_args()
cfg <- read_module_config(opts$config)$sctenifoldknk
if (is.null(cfg)) stop("Missing sctenifoldknk section in config")

required_parameters <- c(
  "package_version", "target_gene", "annotation_column", "malignant_states", "network_genes",
  "hvg_candidates", "nc_nNet", "nc_nCells", "nc_nComp", "td_K",
  "ma_nDim", "dr_abs_z_threshold", "dr_raw_p_threshold",
  "enrichment_fdr"
)
missing_parameters <- setdiff(required_parameters, names(cfg))
if (length(missing_parameters)) {
  stop("Missing scTenifoldKnk parameters: ", paste(missing_parameters, collapse = ", "))
}
if (!identical(cfg$target_gene, "SPP1")) {
  stop("The final manuscript workflow is locked to SPP1")
}
installed_version <- as.character(packageVersion("scTenifoldKnk"))
if (!identical(installed_version, cfg$package_version)) {
  stop(
    "scTenifoldKnk ", cfg$package_version, " is required; installed ",
    installed_version
  )
}

input_path <- require_input(
  opts$input_dir,
  "utuc_malignant_epithelial.rds",
  "UTUC single-cell Seurat object"
)
object <- readRDS(input_path)
if (!inherits(object, "Seurat")) stop("Input must be a Seurat object")
if (!"RNA" %in% Assays(object)) stop("Input lacks an RNA assay")
DefaultAssay(object) <- "RNA"

metadata <- object[[]]
if (!cfg$annotation_column %in% names(metadata)) {
  stop("Missing cell-state column: ", cfg$annotation_column)
}
malignant_cells <- rownames(metadata)[
  metadata[[cfg$annotation_column]] %in% unlist(cfg$malignant_states)
]
if (!length(malignant_cells)) {
  stop("No Cancer_c0-Cancer_c4 malignant epithelial cells were found")
}
object <- subset(object, cells = malignant_cells)

counts <- tryCatch(
  GetAssayData(object, assay = "RNA", layer = "counts"),
  error = function(e) GetAssayData(object, assay = "RNA", slot = "counts")
)
counts <- counts[Matrix::rowSums(counts) > 0, , drop = FALSE]
if (!cfg$target_gene %in% rownames(counts)) {
  stop(cfg$target_gene, " is absent from malignant epithelial raw counts")
}
if (ncol(counts) < cfg$nc_nCells) {
  stop("At least ", cfg$nc_nCells, " malignant cells are required; found ", ncol(counts))
}
count_values <- if (inherits(counts, "sparseMatrix")) counts@x else as.numeric(counts)
if (any(count_values < 0) || any(abs(count_values - round(count_values)) > 1e-8)) {
  stop("scTenifoldKnk requires a non-negative integer raw-count matrix")
}

# Match the final UTUC run: select 1,000 network genes from 2,500 candidate
# HVGs, force-retain SPP1, and remove common technical gene families.
object <- NormalizeData(object, verbose = FALSE)
object <- FindVariableFeatures(
  object,
  selection.method = "vst",
  nfeatures = cfg$hvg_candidates,
  verbose = FALSE
)
technical_pattern <- "^(MT-|RPL|RPS|HBA[12]$|HBB$|HBD$|HBG[12]$)"
hvg <- VariableFeatures(object)
hvg <- hvg[!grepl(technical_pattern, hvg, ignore.case = TRUE)]
hvg <- setdiff(hvg, cfg$target_gene)
network_genes <- c(cfg$target_gene, head(hvg, cfg$network_genes - 1L))
if (length(network_genes) != cfg$network_genes) {
  stop("Unable to construct the locked ", cfg$network_genes, "-gene network")
}
network_counts <- as.matrix(counts[network_genes, , drop = FALSE])

set.seed(opts$seed)
result <- scTenifoldKnk(
  countMatrix = network_counts,
  gKO = cfg$target_gene,
  qc = FALSE,
  nc_nNet = cfg$nc_nNet,
  nc_nCells = cfg$nc_nCells,
  nc_nComp = cfg$nc_nComp,
  td_K = cfg$td_K,
  ma_nDim = cfg$ma_nDim,
  nCores = opts$threads
)

dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
saveRDS(result, file.path(opts$output_dir, "utuc_epithelial_spp1_virtual_knockout.rds"))
write.table(
  result$diffRegulation,
  file.path(opts$output_dir, "utuc_epithelial_spp1_differential_regulation.tsv"),
  sep = "\t", quote = FALSE, row.names = FALSE
)
writeLines(
  network_genes,
  file.path(opts$output_dir, "utuc_epithelial_spp1_network_genes.txt")
)

# The threshold below reproduces the finalized figure-generating workflow. It
# selects network-perturbed genes for over-representation analysis; Z signs
# must not be interpreted as transcriptional up/down-regulation.
dr <- result$diffRegulation
selected <- dr[
  dr$gene != cfg$target_gene &
    abs(dr$Z) > cfg$dr_abs_z_threshold &
    dr$p.value < cfg$dr_raw_p_threshold,
  , drop = FALSE
]
selected <- selected[order(-abs(selected$Z)), , drop = FALSE]
write.table(
  selected,
  file.path(opts$output_dir, "utuc_epithelial_spp1_selected_dr_genes.tsv"),
  sep = "\t", quote = FALSE, row.names = FALSE
)
if (nrow(selected) < 3L) stop("Too few DR genes for GO/KEGG enrichment")

mapped <- unique(bitr(
  selected$gene,
  fromType = "SYMBOL",
  toType = "ENTREZID",
  OrgDb = org.Hs.eg.db
))
go_result <- enrichGO(
  gene = mapped$ENTREZID,
  OrgDb = org.Hs.eg.db,
  keyType = "ENTREZID",
  ont = "ALL",
  pAdjustMethod = "BH",
  pvalueCutoff = cfg$dr_raw_p_threshold,
  qvalueCutoff = 0.2,
  readable = TRUE
)
kegg_result <- tryCatch(
  enrichKEGG(
    gene = mapped$ENTREZID,
    organism = "hsa",
    pvalueCutoff = cfg$dr_raw_p_threshold,
    pAdjustMethod = "BH"
  ),
  error = function(e) {
    warning("KEGG enrichment was unavailable: ", conditionMessage(e))
    NULL
  }
)
go_table <- as.data.frame(go_result)
kegg_table <- if (is.null(kegg_result)) data.frame() else as.data.frame(kegg_result)
if (nrow(kegg_table)) kegg_table$ONTOLOGY <- "KEGG"
common_columns <- intersect(names(go_table), names(kegg_table))
enrichment <- if (nrow(kegg_table)) {
  rbind(go_table[, common_columns, drop = FALSE], kegg_table[, common_columns, drop = FALSE])
} else {
  go_table
}
if (!nrow(enrichment)) stop("No GO/KEGG enrichment terms were returned")
write.table(
  enrichment,
  file.path(opts$output_dir, "utuc_epithelial_spp1_go_kegg_all.tsv"),
  sep = "\t", quote = FALSE, row.names = FALSE
)

panel_table <- enrichment[
  !is.na(enrichment$p.adjust) & enrichment$p.adjust < cfg$enrichment_fdr,
  , drop = FALSE
]
panel_table <- data.frame(
  pathway = panel_table$Description,
  ontology = panel_table$ONTOLOGY,
  gene_count = panel_table$Count,
  FDR = panel_table$p.adjust,
  neg_log10_FDR = -log10(pmax(panel_table$p.adjust, .Machine$double.xmin)),
  stringsAsFactors = FALSE
)
write.table(
  panel_table,
  file.path(opts$output_dir, "Fig08_B.tsv"),
  sep = "\t", quote = FALSE, row.names = FALSE
)

write_run_metadata(
  opts$output_dir,
  "utuc_malignant_epithelial_spp1_virtual_knockout",
  opts,
  list(
    package_version = installed_version,
    target = cfg$target_gene,
    compartment = "Cancer_c0-Cancer_c4 malignant epithelial cells",
    n_input_cells = ncol(network_counts),
    n_network_genes = nrow(network_counts),
    nc_nNet = cfg$nc_nNet,
    nc_nCells = cfg$nc_nCells,
    nc_nComp = cfg$nc_nComp,
    td_K = cfg$td_K,
    ma_nDim = cfg$ma_nDim,
    interpretation_scope = paste(
      "Network-level perturbation association only; not directional",
      "expression change or proof of TAM-to-CAF causality"
    )
  )
)
