#!/usr/bin/env bash
set -euo pipefail

input_loom="${1:?usage: 04_pyscenic.sh INPUT_LOOM TF_LIST MOTIF_DB MOTIF_ANNOT OUTPUT_DIR [THREADS]}"
tf_list="${2:?missing TF list}"
motif_db="${3:?missing motif database}"
motif_annot="${4:?missing motif annotation}"
output_dir="${5:?missing output directory}"
threads="${6:-4}"

mkdir -p "$output_dir"

pyscenic grn \
  "$input_loom" "$tf_list" \
  -o "$output_dir/adjacencies.tsv" \
  --num_workers "$threads"

pyscenic ctx \
  "$output_dir/adjacencies.tsv" "$motif_db" \
  --annotations_fname "$motif_annot" \
  --expression_mtx_fname "$input_loom" \
  --output "$output_dir/regulons.csv" \
  --num_workers "$threads"

pyscenic aucell \
  "$input_loom" "$output_dir/regulons.csv" \
  --output "$output_dir/auc_mtx.loom" \
  --num_workers "$threads"

