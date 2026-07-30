#!/usr/bin/env Rscript

# Reusable within-lineage Seurat workflow for malignant epithelial, myeloid,
# neutrophil, lymphoid, mesenchymal and endothelial subclustering.

suppressPackageStartupMessages({
  library(dplyr)
  library(harmony)
  library(readr)
  library(Seurat)
  library(yaml)
})

source(file.path("core", "R", "cli.R"))
opts <- parse_common_args()
all_cfg <- yaml::read_yaml(opts$config)
cfg <- all_cfg$single_cell
sub_cfg <- all_cfg$subclustering
if (is.null(sub_cfg)) stop("Config requires a subclustering section")
set.seed(opts$seed)

required_config <- c(
  "input_file", "metadata_field", "include_values", "output_prefix"
)
missing_config <- setdiff(required_config, names(sub_cfg))
if (length(missing_config)) {
  stop("Missing subclustering config: ", paste(missing_config, collapse = ", "))
}

object <- readRDS(require_input(opts$input_dir, sub_cfg$input_file))
if (!inherits(object, "Seurat")) stop("Input must be a Seurat object")
if (!sub_cfg$metadata_field %in% names(object[[]])) {
  stop("Metadata field absent: ", sub_cfg$metadata_field)
}
keep <- rownames(object[[]])[
  object[[]][[sub_cfg$metadata_field]] %in% unlist(sub_cfg$include_values)
]
if (length(keep) < 20L) stop("Fewer than 20 cells remain after lineage selection")
object <- subset(object, cells = keep)
DefaultAssay(object) <- "RNA"

object <- NormalizeData(
  object,
  normalization.method = "LogNormalize",
  scale.factor = cfg$normalization_scale_factor,
  verbose = FALSE
)
object <- FindVariableFeatures(
  object,
  selection.method = "vst",
  nfeatures = cfg$highly_variable_genes,
  verbose = FALSE
)
object <- ScaleData(object, features = VariableFeatures(object), verbose = FALSE)
object <- RunPCA(
  object,
  features = VariableFeatures(object),
  npcs = cfg$pca_dimensions,
  verbose = FALSE
)

batch_key <- if (is.null(sub_cfg$batch_key)) "orig.ident" else sub_cfg$batch_key
use_harmony <- batch_key %in% names(object[[]]) &&
  length(unique(object[[]][[batch_key]])) > 1L
reduction <- "pca"
if (use_harmony) {
  object <- RunHarmony(
    object,
    group.by.vars = batch_key,
    reduction.use = "pca",
    dims.use = seq_len(cfg$pca_dimensions),
    verbose = FALSE
  )
  reduction <- "harmony"
}

resolution <- if (is.null(sub_cfg$cluster_resolution)) {
  cfg$cluster_resolution
} else {
  sub_cfg$cluster_resolution
}
object <- FindNeighbors(
  object,
  reduction = reduction,
  dims = seq_len(cfg$pca_dimensions),
  verbose = FALSE
)
object <- FindClusters(
  object,
  resolution = resolution,
  random.seed = opts$seed,
  verbose = FALSE
)
object <- RunUMAP(
  object,
  reduction = reduction,
  dims = seq_len(cfg$pca_dimensions),
  seed.use = opts$seed,
  verbose = FALSE
)
object <- RunTSNE(
  object,
  reduction = reduction,
  dims = seq_len(cfg$pca_dimensions),
  seed.use = opts$seed,
  check_duplicates = FALSE
)

markers <- FindAllMarkers(
  object,
  assay = "RNA",
  test.use = "wilcox",
  only.pos = TRUE,
  min.pct = cfg$marker_min_percent,
  logfc.threshold = cfg$marker_log2fc,
  random.seed = opts$seed
) %>%
  filter(p_val_adj < cfg$marker_fdr)

umap <- as.data.frame(Embeddings(object, "umap"))
umap$cell_id <- rownames(umap)
umap$seurat_cluster <- as.character(Idents(object)[umap$cell_id])
tsne <- as.data.frame(Embeddings(object, "tsne"))
tsne$cell_id <- rownames(tsne)
tsne$seurat_cluster <- as.character(Idents(object)[tsne$cell_id])

dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
saveRDS(
  object,
  file.path(opts$output_dir, paste0(sub_cfg$output_prefix, "_subclustered.rds"))
)
write_tsv(
  markers,
  file.path(opts$output_dir, paste0(sub_cfg$output_prefix, "_markers.tsv.gz"))
)
write_tsv(
  umap,
  file.path(opts$output_dir, paste0(sub_cfg$output_prefix, "_umap.tsv.gz"))
)
write_tsv(
  tsne,
  file.path(opts$output_dir, paste0(sub_cfg$output_prefix, "_tsne.tsv.gz"))
)
write_run_metadata(
  opts$output_dir,
  paste0("single_cell_subclustering_", sub_cfg$output_prefix),
  opts,
  list(
    selection_field = sub_cfg$metadata_field,
    selection_values = unlist(sub_cfg$include_values),
    cells_retained = ncol(object),
    integration = if (use_harmony) paste("Harmony by", batch_key) else "PCA",
    dimensions = cfg$pca_dimensions,
    cluster_resolution = resolution
  )
)
