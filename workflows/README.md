# Manuscript analysis workflows

This folder gives the article-level computational framework. It is more
substantive than pseudocode, but deliberately omits private paths, raw patient
data, large intermediate objects and exploratory notebooks.

## Overall order

1. `single_cell/`: quality control, integration, annotation, lineage
   reclustering, inferCNV, trajectory and functional programs.
2. `genetics/`: FinnGen GWAS integration using the original `scPagwas_main`
   workflow.
3. `spatial/`: Visium processing, cell2location, spatial neighborhoods,
   multiscale pair burden, permutation O/E and signed-distance profiles.
4. `communication/`: CellChat and the TAM-to-myCAF NicheNet candidate network.
5. `perturbation/`: malignant-epithelial SPP1 virtual knockout.
6. `bulk_clinical_validation/`: subtype/TME analyses and independent
   Japan-UTUC clinical models.

The spatial and Japan-UTUC branches are intentionally separate. Japan-UTUC
bulk scores quantify patient-level cellular-program abundance and clinical
association; they do not measure spatial adjacency.

See `00_pipeline_overview.R` for the input-output hand-off between these
workflows and the figure folders.
