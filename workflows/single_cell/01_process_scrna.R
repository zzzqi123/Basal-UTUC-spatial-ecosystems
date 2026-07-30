#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(Seurat)
  library(harmony)
  library(yaml)
})

source(file.path("core", "R", "cli.R"))
opts <- parse_common_args()
cfg <- yaml::read_yaml(opts$config)$single_cell
set.seed(opts$seed)

input_path <- require_input(opts$input_dir, "utuc_raw_seurat.rds")
object <- readRDS(input_path)
if (!inherits(object, "Seurat")) stop("Input must be a Seurat object")

object[["percent.mt"]] <- PercentageFeatureSet(object, pattern = "^MT-")
object[["percent.hb"]] <- PercentageFeatureSet(
  object,
  pattern = "^HB[^(P)]"
)
object <- subset(
  object,
  subset =
    nFeature_RNA >= cfg$min_features &
    nFeature_RNA <= cfg$max_features &
    percent.mt < cfg$max_mito_percent &
    percent.hb < cfg$max_hemoglobin_percent
)
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
object <- RunHarmony(
  object,
  group.by.vars = "orig.ident",
  reduction.use = "pca",
  dims.use = seq_len(cfg$pca_dimensions),
  verbose = FALSE
)
object <- FindNeighbors(
  object,
  reduction = "harmony",
  dims = seq_len(cfg$pca_dimensions),
  verbose = FALSE
)
object <- FindClusters(
  object,
  resolution = cfg$cluster_resolution,
  random.seed = opts$seed,
  verbose = FALSE
)
object <- RunUMAP(
  object,
  reduction = "harmony",
  dims = seq_len(cfg$pca_dimensions),
  seed.use = opts$seed,
  verbose = FALSE
)
object <- RunTSNE(
  object,
  reduction = "harmony",
  dims = seq_len(cfg$pca_dimensions),
  seed.use = opts$seed,
  check_duplicates = FALSE
)

dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
saveRDS(object, file.path(opts$output_dir, "utuc_scrna_processed.rds"))
write_run_metadata(
  opts$output_dir,
  "single_cell_preprocessing",
  opts,
  list(
    integration = "Harmony by orig.ident",
    dimensions = cfg$pca_dimensions,
    cluster_resolution = cfg$cluster_resolution
  )
)
