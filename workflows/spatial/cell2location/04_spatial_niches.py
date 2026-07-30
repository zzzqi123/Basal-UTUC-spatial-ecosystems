#!/usr/bin/env python3
"""Build q05 abundance neighbours and Leiden spatial niches."""

from __future__ import annotations

import sys
from pathlib import Path

import scanpy as sc

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT))

from core.python.common import (  # noqa: E402
    common_parser,
    load_yaml,
    require_file,
    write_run_metadata,
)


def main() -> None:
    parser = common_parser(__doc__)
    parser.add_argument("--input", default="spatial_cell2location_posterior.h5ad")
    parser.add_argument("--output", default="spatial_with_niches.h5ad")
    args = parser.parse_args()
    cfg = load_yaml(args.config)["cell2location"]

    input_path = require_file(args.input_dir / args.input, "posterior AnnData")
    args.output_dir.mkdir(parents=True, exist_ok=True)
    adata = sc.read_h5ad(input_path)
    q05_key = cfg["conservative_abundance_key"]
    if q05_key not in adata.obsm:
        raise KeyError(f"Missing conservative abundance matrix: {q05_key}")

    sc.pp.neighbors(
        adata,
        use_rep=q05_key,
        n_neighbors=int(cfg["neighbors"]),
        random_state=args.seed,
    )
    sc.tl.leiden(
        adata,
        resolution=float(cfg["leiden_resolution"]),
        key_added="spatial_niche",
        random_state=args.seed,
    )
    sc.tl.umap(adata, random_state=args.seed)
    adata.obs[["spatial_niche"]].to_csv(
        args.output_dir / "spatial_niche_assignments.tsv",
        sep="\t",
    )
    adata.write_h5ad(args.output_dir / args.output)
    write_run_metadata(
        args.output_dir,
        workflow="cell2location_spatial_niches",
        config=args.config,
        seed=args.seed,
        threads=args.threads,
        extra={
            "abundance_key": q05_key,
            "neighbors": int(cfg["neighbors"]),
            "leiden_resolution": float(cfg["leiden_resolution"]),
        },
    )


if __name__ == "__main__":
    main()
