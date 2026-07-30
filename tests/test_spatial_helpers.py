#!/usr/bin/env python3

import sys
from pathlib import Path

import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from core.python.spatial import pair_burden, section_scale_total_abundance

abundance = pd.DataFrame({"A": [4.0, 0.0], "B": [9.0, 1.0]})
observed = pair_burden(abundance, "A", "B")
np.testing.assert_allclose(observed.to_numpy(), [6.0, 0.0])

section = pd.Series(["S1", "S2"])
scaled = section_scale_total_abundance(abundance, section)
assert scaled.shape == abundance.shape
assert np.isfinite(scaled.to_numpy()).all()
print("PASS: project-authored spatial helper smoke tests")
