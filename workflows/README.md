# Manuscript analysis workflows

This folder contains the analysis workflows used across multiple figures.
Inputs and outputs are passed by command-line arguments; raw patient data,
large intermediate objects and exploratory notebooks remain local.

## Overall order

1. `single_cell/`: quality control, integration, annotation, lineage
   reclustering, primary and sensitivity inferCNV, Monocle2/SCOP-Monocle3
   trajectories, SCENIC, marker visualization, composition and functional
   programs, single-cell CellChat/NicheNet and the final malignant-epithelial
   SPP1 virtual knockout.
2. `genetics/`: FinnGen GWAS integration using the original `scPagwas_main`
   workflow and SPP1 PheW-MR/SMR-HEIDI result processing.
3. `spatial/`: Visium processing, single-cell-reference deconvolution by
   cell2location/RCTD, spatial neighborhoods, SpaGene, SpaCET, spatial
   CellChat, multiscale pair burden and signed-distance profiles.
4. `bulk_clinical_validation/`: single-cell-reference CIBERSORTx input/output
   hand-off, ESTIMATE/BASE47 scores, subtype/TME interaction models,
   survival/ROC analyses and independent Japan-UTUC clinical models.

The spatial and Japan-UTUC branches are kept separate. Japan-UTUC
bulk scores quantify patient-level cellular-program abundance and clinical
association; they do not measure spatial adjacency.

See `00_pipeline_overview.R` for the input-output hand-off between these
workflows and the figure folders. The Methods-to-script index is in
`../manifests/method_index.tsv`.
