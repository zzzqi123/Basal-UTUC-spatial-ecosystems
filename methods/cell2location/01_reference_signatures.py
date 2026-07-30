#!/usr/bin/env python3
"""Estimate cell-state reference signatures using cell2location NB regression."""

from __future__ import annotations

import sys
from pathlib import Path

import scanpy as sc
from cell2location.models import RegressionModel

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))

from functions.python.common import (  # noqa: E402
    common_parser,
    load_yaml,
    require_file,
    validate_raw_counts,
    write_run_metadata,
)


def main() -> None:
    parser = common_parser(__doc__)
    parser.add_argument("--input", default="utuc_scrna_counts.h5ad")
    parser.add_argument("--output", default="reference_signatures.h5ad")
    args = parser.parse_args()
    cfg = load_yaml(args.config)["cell2location"]

    input_path = require_file(args.input_dir / args.input, "single-cell counts")
    args.output_dir.mkdir(parents=True, exist_ok=True)
    adata = sc.read_h5ad(input_path)
    validate_raw_counts(adata.X)

    batch_key = cfg["reference_batch_key"]
    label_key = cfg["reference_label_key"]
    for key in (batch_key, label_key):
        if key not in adata.obs:
            raise KeyError(f"Required adata.obs field not found: {key}")

    RegressionModel.setup_anndata(
        adata=adata,
        batch_key=batch_key,
        labels_key=label_key,
    )
    model = RegressionModel(adata)
    model.train(max_epochs=int(cfg["reference_max_epochs"]))
    adata = model.export_posterior(
        adata,
        sample_kwargs={
            "num_samples": int(cfg["posterior_samples"]),
            "batch_size": 2500,
        },
    )
    adata = model.export_posterior(
        adata,
        use_quantiles=True,
        add_to_varm=["q05", "q50", "q95"],
        sample_kwargs={"batch_size": 2500},
    )
    model.save(args.output_dir / "reference_model", overwrite=True)
    adata.write_h5ad(args.output_dir / args.output)
    write_run_metadata(
        args.output_dir,
        workflow="cell2location_reference_signatures",
        config=args.config,
        seed=args.seed,
        threads=args.threads,
        extra={
            "batch_key": batch_key,
            "label_key": label_key,
            "max_epochs": int(cfg["reference_max_epochs"]),
        },
    )


if __name__ == "__main__":
    main()

