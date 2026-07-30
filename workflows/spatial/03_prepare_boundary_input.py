#!/usr/bin/env python3
"""Prepare posterior-mean malignant fractions and normalized coordinates."""

from __future__ import annotations

import sys
from pathlib import Path

import anndata as ad
import numpy as np
import pandas as pd
from scipy.spatial import cKDTree
from skimage.filters import threshold_otsu

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))

from core.python.common import (  # noqa: E402
    common_parser,
    load_yaml,
    require_file,
    write_run_metadata,
)
from core.python.spatial import clean_abundance_columns  # noqa: E402

TARGET_STATES = (
    "Macro_c0_SPP1",
    "CAF_c3_POSTN",
    "Neu_c2_VEGFA",
    "Endo_c1_CXCR4",
    "Cancer_c3",
)


def main() -> None:
    parser = common_parser(__doc__)
    parser.add_argument("--input", default="spatial_cell2location_posterior.h5ad")
    parser.add_argument("--section-column", default="sample")
    args = parser.parse_args()
    config = load_yaml(args.config)
    abundance_key = config["cell2location"]["mean_abundance_key"]

    input_path = require_file(args.input_dir / args.input, "posterior AnnData")
    adata = ad.read_h5ad(input_path)
    if abundance_key not in adata.obsm:
        raise KeyError(f"Posterior-mean abundance not found: {abundance_key}")
    if args.section_column not in adata.obs:
        raise KeyError(f"Section column not found: {args.section_column}")

    abundance = clean_abundance_columns(
        pd.DataFrame(adata.obsm[abundance_key], index=adata.obs_names)
    )
    cancer_columns = [
        column for column in abundance.columns if column.startswith("Cancer_c")
    ]
    if not cancer_columns:
        raise KeyError("No malignant epithelial Cancer_c* states were found")
    missing_targets = set(TARGET_STATES).difference(abundance.columns)
    if missing_targets:
        raise KeyError(f"Missing target states: {sorted(missing_targets)}")

    coordinates = np.asarray(adata.obsm["spatial"], dtype=float)
    output_tables = []
    thresholds = []
    sections = adata.obs[args.section_column].astype(str)

    for section in sections.unique():
        keep = sections.eq(section).to_numpy()
        section_abundance = abundance.loc[keep]
        section_coordinates = coordinates[keep]
        total = section_abundance.sum(axis=1).clip(lower=np.finfo(float).eps)
        malignant_fraction = section_abundance[cancer_columns].sum(axis=1) / total
        threshold = float(threshold_otsu(malignant_fraction.to_numpy()))
        nearest = cKDTree(section_coordinates).query(section_coordinates, k=2)[0][:, 1]
        spacing = float(np.median(nearest))

        table = pd.DataFrame(
            {
                "spot_id": section_abundance.index.astype(str),
                "sample": section,
                "x_nn": section_coordinates[:, 0] / spacing,
                "y_nn": section_coordinates[:, 1] / spacing,
                "malignant_fraction": malignant_fraction.to_numpy(),
                "tumor_type": np.where(
                    malignant_fraction.to_numpy() >= threshold,
                    "Tumor",
                    "Non_tumor",
                ),
            }
        )
        for state in TARGET_STATES:
            table[state] = section_abundance[state].to_numpy(dtype=float)
        output_tables.append(table)
        thresholds.append(
            {
                "sample": section,
                "otsu_threshold": threshold,
                "median_nearest_neighbor_pixels": spacing,
                "n_tumor_spots": int(table["tumor_type"].eq("Tumor").sum()),
                "n_non_tumor_spots": int(table["tumor_type"].eq("Non_tumor").sum()),
            }
        )

    args.output_dir.mkdir(parents=True, exist_ok=True)
    pd.concat(output_tables, ignore_index=True).to_csv(
        args.output_dir / "stgrads_interface_input.tsv",
        sep="\t",
        index=False,
    )
    pd.DataFrame(thresholds).to_csv(
        args.output_dir / "tumor_reference_thresholds.tsv",
        sep="\t",
        index=False,
    )
    write_run_metadata(
        args.output_dir,
        workflow="prepare_stgrads_tumor_interface",
        config=args.config,
        seed=args.seed,
        threads=args.threads,
        extra={
            "abundance_key": abundance_key,
            "tumor_reference": "section-specific Otsu threshold of malignant fraction",
            "coordinate_unit": "median nearest-neighbour Visium spacing",
        },
    )


if __name__ == "__main__":
    main()
