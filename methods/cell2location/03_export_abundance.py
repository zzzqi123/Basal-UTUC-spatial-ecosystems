#!/usr/bin/env python3
"""Export posterior cell-state abundance summaries from a trained model."""

from __future__ import annotations

import sys
from pathlib import Path

import scanpy as sc
from cell2location.models import Cell2location

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))

from functions.python.common import (  # noqa: E402
    common_parser,
    load_yaml,
    require_file,
    write_run_metadata,
)


def main() -> None:
    parser = common_parser(__doc__)
    parser.add_argument("--input", default="spatial_trained.h5ad")
    parser.add_argument("--model-dir", default="spatial_model")
    parser.add_argument("--output", default="spatial_cell2location_posterior.h5ad")
    args = parser.parse_args()
    cfg = load_yaml(args.config)["cell2location"]

    adata_path = require_file(args.input_dir / args.input, "trained spatial AnnData")
    model_path = args.input_dir / args.model_dir
    if not model_path.is_dir():
        raise FileNotFoundError(f"Missing trained model directory: {model_path}")

    args.output_dir.mkdir(parents=True, exist_ok=True)
    adata = sc.read_h5ad(adata_path)
    model = Cell2location.load(model_path, adata)
    adata = model.export_posterior(
        adata,
        sample_kwargs={
            "num_samples": int(cfg["posterior_samples"]),
            "batch_size": model.adata.n_obs,
        },
    )
    required = {
        cfg["conservative_abundance_key"],
        cfg["mean_abundance_key"],
        "q95_cell_abundance_w_sf",
    }
    missing = required.difference(adata.obsm.keys())
    if missing:
        raise KeyError(f"Posterior export is missing: {sorted(missing)}")
    adata.write_h5ad(args.output_dir / args.output)
    write_run_metadata(
        args.output_dir,
        workflow="cell2location_export_posterior",
        config=args.config,
        seed=args.seed,
        threads=args.threads,
        extra={
            "posterior_samples": int(cfg["posterior_samples"]),
            "q05_key": cfg["conservative_abundance_key"],
            "mean_key": cfg["mean_abundance_key"],
        },
    )


if __name__ == "__main__":
    main()

