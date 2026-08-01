#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_dir"

python_bin="${PYTHON_BIN:-python3}"

"$python_bin" tests/check_manifest.py
"$python_bin" tests/check_method_audit.py
"$python_bin" tests/check_architecture.py
"$python_bin" tests/check_parameters.py
"$python_bin" tests/check_privacy.py
"$python_bin" tests/test_spatial_helpers.py
"$python_bin" -m compileall -q core workflows tests tools

if command -v Rscript >/dev/null 2>&1; then
  Rscript tests/test_cibersortx_handoff.R
  while IFS= read -r script; do
    Rscript -e "parse(file='$script')" >/dev/null
  done < <(find core workflows figures supplementary -type f -name '*.R' | sort)
  echo "PASS: R scripts parse"
else
  echo "SKIP: Rscript is not available; R parse check not run"
fi

echo "PASS: repository validation complete"
