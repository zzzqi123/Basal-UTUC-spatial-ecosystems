#!/usr/bin/env python3
"""Train cell2location spatial mapping using manuscript-locked parameters."""

from __future__ import annotations

import sys
from pathlib import Path

import numpy as np
import scanpy as sc
from cell2location.models import Cell2location

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT))

from core.python.common import (  # noqa: E402
    common_parser,
    load_yaml,
    require_file,
    validate_raw_counts,
    write_run_metadata,
)


def reference_signatures(adata_ref):
    factor_names = list(adata_ref.uns["mod"]["factor_names"])
    column_names = [f"means_per_cluster_mu_fg_{name}" for name in factor_names]
    if "means_per_cluster_mu_fg" in adata_ref.varm:
        signatures = adata_ref.varm["means_per_cluster_mu_fg"][column_names].copy()
    else:
        signatures = adata_ref.var[column_names].copy()
    signatures.columns = factor_names
    return signatures


def main() -> None:
    parser = common_parser(__doc__)
    parser.add_argument("--spatial-input", default="spatial_counts.h5ad")
    parser.add_argument("--reference-input", default="reference_signatures.h5ad")
    parser.add_argument("--output", default="spatial_trained.h5ad")
    parser.add_argument("--batch-key", default=None)
    args = parser.parse_args()
    cfg = load_yaml(args.config)["cell2location"]

    spatial_path = require_file(args.input_dir / args.spatial_input, "spatial counts")
    reference_path = require_file(
        args.input_dir / args.reference_input, "reference signatures"
    )
    args.output_dir.mkdir(parents=True, exist_ok=True)

    adata_vis = sc.read_h5ad(spatial_path)
    adata_ref = sc.read_h5ad(reference_path)
    validate_raw_counts(adata_vis.X)
    signatures = reference_signatures(adata_ref)

    shared = np.intersect1d(adata_vis.var_names, signatures.index)
    if len(shared) < 1000:
        raise ValueError(f"Only {len(shared)} genes overlap reference and spatial data")
    adata_vis = adata_vis[:, shared].copy()
    signatures = signatures.loc[shared]

    if args.batch_key:
        if args.batch_key not in adata_vis.obs:
            raise KeyError(f"Spatial batch key not found: {args.batch_key}")
        Cell2location.setup_anndata(adata=adata_vis, batch_key=args.batch_key)
    else:
        Cell2location.setup_anndata(adata=adata_vis)

    model = Cell2location(
        adata_vis,
        cell_state_df=signatures,
        N_cells_per_location=int(cfg["n_cells_per_location"]),
        detection_alpha=float(cfg["detection_alpha"]),
    )
    model.train(
        max_epochs=int(cfg["spatial_max_epochs"]),
        batch_size=cfg["batch_size"],
        train_size=float(cfg["train_size"]),
    )
    model.save(args.output_dir / "spatial_model", overwrite=True)
    adata_vis.write_h5ad(args.output_dir / args.output)
    write_run_metadata(
        args.output_dir,
        workflow="cell2location_spatial_mapping",
        config=args.config,
        seed=args.seed,
        threads=args.threads,
        extra={
            "N_cells_per_location": int(cfg["n_cells_per_location"]),
            "detection_alpha": float(cfg["detection_alpha"]),
            "max_epochs": int(cfg["spatial_max_epochs"]),
            "batch_size": cfg["batch_size"],
            "train_size": float(cfg["train_size"]),
        },
    )


if __name__ == "__main__":
    main()
