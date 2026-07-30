# Perturbation workflow

`01_spp1_virtual_knockout.R` applies `scTenifoldKnk` only to malignant
epithelial cells. The public workflow records the target gene, sampled cell
count, network ensemble size and random seed.

This branch supports epithelial-intrinsic SPP1 perturbation. It must not be
interpreted as functional proof of macrophage-derived SPP1 signalling to CAFs.

`02_sctenifoldknk_tme_targets.R` records the separate SPP1 and FAP
tumor-microenvironment network perturbations described in the Methods. These
are hypothesis-generating network analyses and do not replace wet-lab
validation.
