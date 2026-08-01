"""Shared command-line and validation helpers for analysis workflows."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import platform
import subprocess
from typing import Any

import numpy as np
import yaml


def common_parser(description: str) -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=description)
    parser.add_argument("--config", required=True, type=Path)
    parser.add_argument("--input-dir", required=True, type=Path)
    parser.add_argument("--output-dir", required=True, type=Path)
    parser.add_argument("--seed", type=int, default=20260730)
    parser.add_argument("--threads", type=int, default=1)
    return parser


def load_yaml(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        result = yaml.safe_load(handle)
    if not isinstance(result, dict):
        raise ValueError(f"Expected a YAML mapping in {path}")
    return result


def require_file(path: Path, label: str) -> Path:
    if not path.is_file():
        raise FileNotFoundError(f"Missing {label}: {path}")
    return path


def validate_raw_counts(matrix: Any, tolerance: float = 1e-8) -> None:
    """Reject negative, non-finite or clearly normalised expression matrices."""
    values = matrix.data if hasattr(matrix, "data") else np.asarray(matrix)
    values = np.asarray(values)
    if not np.isfinite(values).all():
        raise ValueError("Count matrix contains non-finite values")
    if (values < 0).any():
        raise ValueError("Count matrix contains negative values")
    if not np.allclose(values, np.round(values), atol=tolerance):
        raise ValueError(
            "cell2location requires untransformed integer-like counts; "
            "the supplied matrix appears normalised"
        )


def write_run_metadata(
    output_dir: Path,
    *,
    workflow: str,
    config: Path,
    seed: int,
    threads: int,
    extra: dict[str, Any] | None = None,
) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    try:
        git_commit = subprocess.check_output(
            ["git", "rev-parse", "--short=12", "HEAD"],
            text=True,
        ).strip()
    except (OSError, subprocess.CalledProcessError):
        git_commit = None
    payload: dict[str, Any] = {
        "workflow": workflow,
        "config": str(config),
        "seed": seed,
        "threads": threads,
        "git_commit": git_commit,
        "python_version": platform.python_version(),
    }
    if extra:
        payload.update(extra)
    with (output_dir / "run_metadata.json").open("w", encoding="utf-8") as handle:
        json.dump(payload, handle, indent=2, sort_keys=True)
        handle.write("\n")
