#!/usr/bin/env python3
"""Compute q05-based spatial pair burdens without pooling section identities."""

from __future__ import annotations

import sys
from pathlib import Path

import anndata as ad
import pandas as pd

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))

from functions.python.common import (  # noqa: E402
    common_parser,
    load_yaml,
    require_file,
    write_run_metadata,
)
from functions.python.spatial import clean_abundance_columns, pair_burden  # noqa: E402

PAIRS = {
    "SPP1_TAM__FAP_myCAF": ("Macro_c0_SPP1", "CAF_c3_POSTN"),
    "VEGFA_TAN__CXCR4_tip_EC": ("Neu_c2_VEGFA", "Endo_c1_CXCR4"),
}


def main() -> None:
    parser = common_parser(__doc__)
    parser.add_argument("--input", default="spatial_cell2location_posterior.h5ad")
    parser.add_argument("--section-column", default="sample")
    args = parser.parse_args()
    cfg = load_yaml(args.config)["cell2location"]
    path = require_file(args.input_dir / args.input, "posterior AnnData")
    adata = ad.read_h5ad(path)
    key = cfg["conservative_abundance_key"]
    if key not in adata.obsm:
        raise KeyError(f"q05 abundance not found: {key}")
    abundance = clean_abundance_columns(pd.DataFrame(adata.obsm[key], index=adata.obs_names))
    if args.section_column not in adata.obs:
        raise KeyError(f"Section column not found: {args.section_column}")

    rows = []
    for label, (first, second) in PAIRS.items():
        values = pair_burden(abundance, first, second)
        table = pd.DataFrame(
            {
                "spot_id": adata.obs_names,
                "section": adata.obs[args.section_column].astype(str).to_numpy(),
                "program": label,
                "pair_burden": values.to_numpy(),
            }
        )
        rows.append(table)
    output = pd.concat(rows, ignore_index=True)
    args.output_dir.mkdir(parents=True, exist_ok=True)
    output.to_csv(args.output_dir / "spot_pair_burden.tsv", sep="\t", index=False)
    (
        output.groupby(["section", "program"], observed=True)["pair_burden"]
        .agg(["count", "mean", "median"])
        .reset_index()
        .to_csv(args.output_dir / "section_pair_burden.tsv", sep="\t", index=False)
    )
    write_run_metadata(
        args.output_dir,
        workflow="q05_spatial_pair_burden",
        config=args.config,
        seed=args.seed,
        threads=args.threads,
        extra={"abundance_key": key, "unit_of_inference": "section"},
    )


if __name__ == "__main__":
    main()

