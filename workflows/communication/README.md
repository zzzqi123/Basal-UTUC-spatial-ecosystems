# Cell-cell communication analyses

This directory contains project-level workflows reused across Figures 5, 6
and 9.

- `01_cellchat.R`: global and selected cell-state communication using
  `CellChatDB.human`.
- `02_nichenet_tam_to_mycaf.R`: multi-ligand candidate network from
  `Macro_c0_SPP1` sender cells to `CAF_c3_POSTN` receiver cells.
- `03_cellchat_spatial.R`: CellChat spatial mode with Visium coordinates,
  image scale factors, 250-µm interaction range, 100-µm contact range,
  distance scale 3.65 and at least 10 locations per group.

The NicheNet workflow treats SPP1 as one candidate ligand within a multi-ligand
network. The separate SPP1-only malignant-epithelial virtual knockout is kept
with the other single-cell analyses in `../single_cell/10_spp1_virtual_knockout.R`.
