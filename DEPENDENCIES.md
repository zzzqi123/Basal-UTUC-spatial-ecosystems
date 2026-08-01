# Dependency notes

`environment.yml` installs the shared Python environment, R 4.3 and the
widely available CRAN/Bioconductor packages. `renv.lock` records the core R
versions used by the reviewer-facing wrappers.

Several method-specific packages are installed from their official
repositories or Bioconductor and may not be available from the same Conda
channel on every platform:

| Workflow | Required package or CLI |
|---|---|
| inferCNV | `infercnv` |
| CytoTRACE2 | `CytoTRACE2` |
| Monocle3 robustness | `scop` and its Monocle3 environment |
| marker display | `ClusterGVis`, `Nebulosa` |
| pathway activity | `AUCell`, `decoupleR` |
| regulatory network | `pyscenic` plus the human motif databases |
| single-cell communication | `CellChat`, `nichenetr` |
| single-cell virtual knockout | `scTenifoldKnk` 1.0.3, `clusterProfiler`, `org.Hs.eg.db` |
| spatial deconvolution | `spacexr` |
| bulk deconvolution | registered CIBERSORTx web service |
| spatial ligand-receptor | `SpaGene` |
| spatial gene-set score | `SpaCET` |
| spatial boundary | `stGrads` 2.0 |
| spatial niche functions | `clusterProfiler`, `fgsea`, `sandwich` |
| external spatial score | `UCell` |
| bulk scores | `estimate`, `GSVA` |
| survival and ROC | `survminer`, `survival`, `timeROC`, `pROC` |
| PheW-MR | official `SMR` binary and HEIDI output |

Install these packages from the upstream source appropriate to the manuscript
run and record the resolved versions in the run metadata. Third-party source,
motif databases, model weights and vendor software are intentionally not
copied into this repository.
