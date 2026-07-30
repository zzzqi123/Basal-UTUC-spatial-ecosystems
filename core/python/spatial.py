"""Project-authored spatial abundance helpers."""

from __future__ import annotations

import numpy as np
import pandas as pd


def clean_abundance_columns(frame: pd.DataFrame) -> pd.DataFrame:
    prefixes = (
        "q05cell_abundance_w_sf_",
        "meanscell_abundance_w_sf_",
        "q95cell_abundance_w_sf_",
    )
    output = frame.copy()
    output.columns = [
        next((str(name).removeprefix(prefix) for prefix in prefixes if str(name).startswith(prefix)), str(name))
        for name in output.columns
    ]
    return output


def pair_burden(
    abundance: pd.DataFrame,
    first_state: str,
    second_state: str,
    *,
    method: str = "geometric_mean",
) -> pd.Series:
    missing = {first_state, second_state}.difference(abundance.columns)
    if missing:
        raise KeyError(f"Missing abundance columns: {sorted(missing)}")
    first = abundance[first_state].clip(lower=0).astype(float)
    second = abundance[second_state].clip(lower=0).astype(float)
    if method == "product":
        return first * second
    if method == "geometric_mean":
        return np.sqrt(first * second)
    raise ValueError(f"Unsupported pair-burden method: {method}")


def section_scale_total_abundance(
    abundance: pd.DataFrame,
    section: pd.Series,
) -> pd.DataFrame:
    """Scale spot totals to the pooled median while retaining compositions."""
    values = abundance.clip(lower=0).astype(float)
    totals = values.sum(axis=1)
    pooled_median = float(np.nanmedian(totals[totals > 0]))
    section_medians = totals.groupby(section).median()
    scale = section.map(lambda value: pooled_median / section_medians[value])
    return values.mul(scale.to_numpy(), axis=0)


def rank_inverse_normal(values: pd.Series) -> pd.Series:
    from scipy.stats import norm

    ranks = values.rank(method="average", na_option="keep")
    observed = int(ranks.notna().sum())
    return pd.Series(
        norm.ppf((ranks - 0.5) / observed),
        index=values.index,
        name=values.name,
    )

