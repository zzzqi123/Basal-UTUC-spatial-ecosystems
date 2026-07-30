#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(Seurat)
  library(dplyr)
  library(nichenetr)
  library(readr)
})

source(file.path("core", "R", "cli.R"))
opts <- parse_common_args()
object <- readRDS(require_input(opts$input_dir, "utuc_annotated_scrna.rds"))
resources <- readRDS(require_input(opts$input_dir, "nichenet_human_resources.rds"))

sender <- "Macro_c0_SPP1"
receiver <- "CAF_c3_POSTN"
annotation <- "second_celltype_byhand"
if (!annotation %in% names(object[[]])) stop("Missing annotation: ", annotation)

Idents(object) <- annotation
sender_genes <- rownames(
  FindMarkers(object, ident.1 = sender, only.pos = TRUE, min.pct = 0.10)
)
receiver_markers <- FindMarkers(
  object,
  ident.1 = receiver,
  ident.2 = setdiff(levels(Idents(object)), receiver),
  only.pos = TRUE,
  min.pct = 0.10
) %>%
  tibble::rownames_to_column("gene") %>%
  filter(p_val_adj < 0.05, avg_log2FC > 0.25)

geneset <- receiver_markers$gene
background <- rownames(object)
potential_ligands <- intersect(
  sender_genes,
  unique(resources$lr_network$from)
)
ligand_activity <- predict_ligand_activities(
  geneset = geneset,
  background_expressed_genes = background,
  ligand_target_matrix = resources$ligand_target_matrix,
  potential_ligands = potential_ligands
) %>%
  arrange(desc(aupr_corrected))

dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
write_tsv(ligand_activity, file.path(opts$output_dir, "tam_to_mycaf_ligand_activity.tsv"))
write_tsv(receiver_markers, file.path(opts$output_dir, "mycaf_receiver_markers.tsv"))
write_run_metadata(
  opts$output_dir,
  "nichenet_tam_to_mycaf",
  opts,
  list(sender = sender, receiver = receiver, interpretation = "multi-ligand candidate network")
)
