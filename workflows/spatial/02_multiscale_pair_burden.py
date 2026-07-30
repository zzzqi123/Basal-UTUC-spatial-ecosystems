#!/usr/bin/env python3
"""Quantify multiscale pair burden and within-section spatial O/E."""

from __future__ import annotations

from collections import deque
import sys
from pathlib import Path

import anndata as ad
import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))

from core.python.common import (  # noqa: E402
    common_parser,
    load_yaml,
    require_file,
    write_run_metadata,
)
from core.python.spatial import (  # noqa: E402
    clean_abundance_columns,
    section_scale_total_abundance,
)

PAIRS = {
    "SPP1_TAM__FAP_POSTN_myCAF": ("Macro_c0_SPP1", "CAF_c3_POSTN"),
    "VEGFA_TAN__CXCR4_tip_EC": ("Neu_c2_VEGFA", "Endo_c1_CXCR4"),
}


def visium_neighbors(obs: pd.DataFrame) -> list[np.ndarray]:
    """Construct the exact six-neighbour graph from Visium array coordinates."""
    required = {"array_row", "array_col"}
    missing = required.difference(obs.columns)
    if missing:
        raise KeyError(f"Missing Visium coordinate columns: {sorted(missing)}")

    positions = {
        (int(row), int(column)): index
        for index, (row, column) in enumerate(
            zip(obs["array_row"], obs["array_col"])
        )
    }
    offsets = ((0, -2), (0, 2), (-1, -1), (-1, 1), (1, -1), (1, 1))
    graph: list[np.ndarray] = []
    for row, column in zip(obs["array_row"], obs["array_col"]):
        adjacent = [
            positions[(int(row) + dr, int(column) + dc)]
            for dr, dc in offsets
            if (int(row) + dr, int(column) + dc) in positions
        ]
        graph.append(np.asarray(adjacent, dtype=int))
    return graph


def exact_ring_pairs(
    graph: list[np.ndarray],
    max_ring: int,
) -> dict[int, tuple[np.ndarray, np.ndarray]]:
    """Return unordered spot pairs at each exact shortest-path distance."""
    pair_lists: dict[int, list[tuple[int, int]]] = {
        ring: [] for ring in range(max_ring + 1)
    }
    pair_lists[0] = [(index, index) for index in range(len(graph))]

    for source in range(len(graph)):
        distance = {source: 0}
        queue: deque[int] = deque([source])
        while queue:
            current = queue.popleft()
            if distance[current] >= max_ring:
                continue
            for target_value in graph[current]:
                target = int(target_value)
                if target not in distance:
                    distance[target] = distance[current] + 1
                    queue.append(target)
        for target, ring in distance.items():
            if ring > 0 and source < target:
                pair_lists[ring].append((source, target))

    result: dict[int, tuple[np.ndarray, np.ndarray]] = {}
    for ring, pairs in pair_lists.items():
        values = np.asarray(pairs, dtype=int)
        if values.size:
            result[ring] = (values[:, 0], values[:, 1])
        else:
            result[ring] = (
                np.asarray([], dtype=int),
                np.asarray([], dtype=int),
            )
    return result


def symmetric_pair_burden(
    left_root: np.ndarray,
    right_root: np.ndarray,
    first: np.ndarray,
    second: np.ndarray,
) -> float:
    """Mean symmetric geometric pair burden over unordered spot pairs."""
    if not len(first):
        return float("nan")
    values = 0.5 * (
        left_root[first] * right_root[second]
        + right_root[first] * left_root[second]
    )
    return float(np.mean(values))


def permutation_metrics(
    left: np.ndarray,
    right: np.ndarray,
    rings: dict[int, tuple[np.ndarray, np.ndarray]],
    n_permutations: int,
    rng: np.random.Generator,
) -> list[dict[str, float | int]]:
    left_root = np.sqrt(np.clip(left, 0, None))
    right_root = np.sqrt(np.clip(right, 0, None))
    ring_ids = sorted(rings)
    observed = {
        ring: symmetric_pair_burden(left_root, right_root, *rings[ring])
        for ring in ring_ids
    }
    null = np.full((n_permutations, len(ring_ids)), np.nan, dtype=float)

    for permutation in range(n_permutations):
        permuted = right_root[rng.permutation(len(right_root))]
        for index, ring in enumerate(ring_ids):
            null[permutation, index] = symmetric_pair_burden(
                left_root,
                permuted,
                *rings[ring],
            )

    rows: list[dict[str, float | int]] = []
    for index, ring in enumerate(ring_ids):
        null_values = null[:, index]
        null_mean = float(np.nanmean(null_values))
        observed_value = observed[ring]
        rows.append(
            {
                "ring": ring,
                "n_spot_pairs": int(len(rings[ring][0])),
                "pair_burden": observed_value,
                "permuted_mean": null_mean,
                "spatial_oe": (
                    observed_value / null_mean if null_mean > 0 else float("nan")
                ),
                "permutation_p_upper": float(
                    (1 + np.sum(null_values >= observed_value))
                    / (n_permutations + 1)
                ),
            }
        )
    return rows


def main() -> None:
    parser = common_parser(__doc__)
    parser.add_argument("--input", default="spatial_cell2location_posterior.h5ad")
    parser.add_argument("--section-column", default="sample")
    parser.add_argument("--stage-column", default="stage")
    args = parser.parse_args()

    config = load_yaml(args.config)
    c2l = config["cell2location"]
    spatial = config["spatial_multiscale"]
    max_ring = int(spatial["max_ring"])
    n_permutations = int(spatial["permutations"])
    rng = np.random.default_rng(args.seed)

    input_path = require_file(args.input_dir / args.input, "posterior AnnData")
    adata = ad.read_h5ad(input_path)
    abundance_key = c2l["conservative_abundance_key"]
    if abundance_key not in adata.obsm:
        raise KeyError(f"Conservative abundance matrix not found: {abundance_key}")
    if args.section_column not in adata.obs:
        raise KeyError(f"Section column not found: {args.section_column}")
    if args.stage_column not in adata.obs:
        raise KeyError(f"Stage column not found: {args.stage_column}")

    abundance = clean_abundance_columns(
        pd.DataFrame(adata.obsm[abundance_key], index=adata.obs_names)
    )
    missing_states = {
        state for pair in PAIRS.values() for state in pair
    }.difference(abundance.columns)
    if missing_states:
        raise KeyError(f"Missing cell-state abundances: {sorted(missing_states)}")

    section_labels = adata.obs[args.section_column].astype(str)
    section_stage = (
        adata.obs[[args.section_column, args.stage_column]]
        .astype(str)
        .drop_duplicates()
    )
    if section_stage[args.section_column].duplicated().any():
        raise ValueError("Each section must have exactly one stage label")
    stage_lookup = dict(
        zip(
            section_stage[args.section_column],
            section_stage[args.stage_column],
        )
    )
    abundance = section_scale_total_abundance(abundance, section_labels)
    rows: list[dict[str, object]] = []

    for section in section_labels.unique():
        keep = section_labels.eq(section).to_numpy()
        section_obs = adata.obs.loc[keep]
        section_abundance = abundance.loc[keep]
        rings = exact_ring_pairs(visium_neighbors(section_obs), max_ring=max_ring)

        for program, (left_state, right_state) in PAIRS.items():
            metrics = permutation_metrics(
                section_abundance[left_state].to_numpy(dtype=float),
                section_abundance[right_state].to_numpy(dtype=float),
                rings,
                n_permutations,
                rng,
            )
            for metric in metrics:
                rows.append(
                    {
                        "section": section,
                        "stage": stage_lookup[section],
                        "program": program,
                        "left_state": left_state,
                        "right_state": right_state,
                        **metric,
                    }
                )

    result = pd.DataFrame(rows)
    nmi_reference = (
        result.loc[result["stage"].str.upper().str.startswith("NMI")]
        .groupby(["program", "ring"], observed=True)["pair_burden"]
        .mean()
        .rename("nmi_reference_burden")
        .reset_index()
    )
    if nmi_reference.empty:
        raise ValueError("An NMI section is required for the descriptive baseline")
    result = result.merge(nmi_reference, on=["program", "ring"], how="left")
    result["fold_vs_nmi"] = (
        result["pair_burden"] / result["nmi_reference_burden"]
    )
    args.output_dir.mkdir(parents=True, exist_ok=True)
    result.to_csv(
        args.output_dir / "multiscale_pair_burden_and_oe.tsv",
        sep="\t",
        index=False,
    )
    write_run_metadata(
        args.output_dir,
        workflow="multiscale_pair_burden_and_spatial_oe",
        config=args.config,
        seed=args.seed,
        threads=args.threads,
        extra={
            "abundance_key": abundance_key,
            "max_ring": max_ring,
            "permutations": n_permutations,
            "unit_of_analysis": "section",
            "interpretation": (
                "Descriptive section-level burden; permutation inference is "
                "performed independently within each section."
            ),
        },
    )


if __name__ == "__main__":
    main()
