# Communication and perturbation analyses

This directory contains project-level wrappers for analyses that are reused
across Figures 5, 6, 8 and 9.

- `01_cellchat.R`: global and selected cell-state communication.
- `02_nichenet_tam_to_mycaf.R`: multi-ligand candidate network from
  `Macro_c0_SPP1` sender cells to `CAF_c3_POSTN` receiver cells.
- `03_spp1_virtual_knockout.R`: epithelial-restricted SPP1 virtual
  perturbation using scTenifoldKnk.

The NicheNet workflow treats SPP1 as one candidate ligand within a multi-ligand
network. The epithelial perturbation workflow is not evidence for
macrophage-derived SPP1 causally activating CAFs.

