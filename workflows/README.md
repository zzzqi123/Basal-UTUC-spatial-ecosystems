# Manuscript analysis workflows

This folder gives the article-level computational framework. It is more
substantive than pseudocode, but deliberately omits private paths, raw patient
data, large intermediate objects and exploratory notebooks.

## Overall order

1. `single_cell/`: quality control, integration, annotation, lineage
   reclustering, primary and sensitivity inferCNV, Monocle2/SCOP-Monocle3
   trajectories, SCENIC, marker visualization, composition and functional
   programs, including the final malignant-epithelial SPP1 virtual knockout.
2. `genetics/`: FinnGen GWAS integration using the original `scPagwas_main`
   workflow and SPP1 PheW-MR/SMR-HEIDI result processing.
3. `spatial/`: Visium processing, cell2location, spatial neighborhoods,
   correlation/co-localization, SpaGene, SpaCET, spatial CellChat, external
   RCTD, multiscale pair burden, permutation O/E and signed-distance profiles.
4. `communication/`: single-cell and spatial CellChat plus the TAM-to-myCAF
   NicheNet candidate network.
5. `bulk_clinical_validation/`: ESTIMATE/BASE47 scores, subtype/TME
   interaction models, survival/ROC analyses and independent Japan-UTUC
   clinical models.

The spatial and Japan-UTUC branches are intentionally separate. Japan-UTUC
bulk scores quantify patient-level cellular-program abundance and clinical
association; they do not measure spatial adjacency.

See `00_pipeline_overview.R` for the input-output hand-off between these
workflows and the figure folders. The line-by-line comparison against the
current manuscript is in `../manifests/manuscript_method_audit.tsv`.
