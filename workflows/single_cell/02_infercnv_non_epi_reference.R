#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(Seurat)
  library(infercnv)
})

source(file.path("core", "R", "cli.R"))
opts <- parse_common_args()
object <- readRDS(require_input(opts$input_dir, "utuc_scrna_annotated.rds"))
gene_order_file <- require_input(opts$input_dir, "grch38_gene_order.tsv")
annotation <- object[[]]
required <- c("orig.ident", "major_celltype", "second_celltype_byhand")
missing <- setdiff(required, names(annotation))
if (length(missing)) stop("Metadata missing: ", paste(missing, collapse = ", "))

reference_lineages <- c("Immune", "Mesenchymal", "Endothelial")
epithelial_lineages <- c("Normal_Epi", "Malignant_Epi")
keep <- annotation$major_celltype %in% c(reference_lineages, epithelial_lineages)
object <- subset(object, cells = rownames(annotation)[keep])
annotation <- object[[]]
annotation$infercnv_group <- ifelse(
  annotation$major_celltype %in% reference_lineages,
  paste0(annotation$orig.ident, "__reference_non_epithelial"),
  paste0(annotation$orig.ident, "__epithelial")
)

dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
annotation_file <- file.path(opts$output_dir, "infercnv_annotations.tsv")
write.table(
  data.frame(cell = rownames(annotation), group = annotation$infercnv_group),
  annotation_file,
  sep = "\t",
  quote = FALSE,
  row.names = FALSE,
  col.names = FALSE
)

counts <- GetAssayData(object, assay = "RNA", layer = "counts")
reference_groups <- unique(
  annotation$infercnv_group[annotation$major_celltype %in% reference_lineages]
)
infercnv_object <- CreateInfercnvObject(
  raw_counts_matrix = counts,
  annotations_file = annotation_file,
  delim = "\t",
  gene_order_file = gene_order_file,
  ref_group_names = reference_groups
)
infercnv_object <- infercnv::run(
  infercnv_object,
  cutoff = 0.1,
  out_dir = file.path(opts$output_dir, "infercnv_run"),
  cluster_by_groups = TRUE,
  denoise = TRUE,
  HMM = FALSE,
  num_threads = opts$threads
)
saveRDS(infercnv_object, file.path(opts$output_dir, "infercnv_non_epi_reference.rds"))
write_run_metadata(
  opts$output_dir,
  "infercnv_non_epithelial_reference",
  opts,
  list(
    reference_lineages = reference_lineages,
    reference_strategy = "within-sample immune, stromal and endothelial cells"
  )
)

