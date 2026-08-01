#!/usr/bin/env python3
"""Validate the final public and controlled data inventory."""

from pathlib import Path
import csv

ROOT = Path(__file__).resolve().parents[1]
manifest = ROOT / "manifests" / "data_manifest.tsv"

with manifest.open(encoding="utf-8") as handle:
    rows = list(csv.DictReader(handle, delimiter="\t"))

if not rows:
    raise SystemExit("Data manifest is empty")

accessions = {row["accession_or_source"] for row in rows}
required = {
    "EGAD00001007667",
    "FinnGen R12",
    "eQTLGen Phase 1",
    "UK Biobank SAIGE PheWeb",
    "GDC TCGA-BLCA",
    "GSE32894",
    "GSE222315",
    "GSE267718",
    "GSE299573",
    "GSE319536",
    "GSE296955",
}
missing = required - accessions
if missing:
    raise SystemExit(f"Data manifest omits final sources: {sorted(missing)}")

allowed = required | {"ACCESSION_PENDING"}
unexpected = accessions - allowed
if unexpected:
    raise SystemExit(f"Data manifest contains non-final sources: {sorted(unexpected)}")

by_accession = {row["accession_or_source"]: row for row in rows}
for accession in ("GSE222315", "GSE267718"):
    if by_accession[accession]["used_in"] != "SuppFig12":
        raise SystemExit(f"{accession} must map to SuppFig12")

expected_spatial = {
    "GSE299573": "Fig07",
    "GSE319536": "Fig07;Fig10;SuppFig06",
    "GSE296955": "Fig07",
}
for accession, figures in expected_spatial.items():
    if by_accession[accession]["used_in"] != figures:
        raise SystemExit(
            f"Unexpected final-figure mapping for {accession}: "
            f"{by_accession[accession]['used_in']}"
        )

print(f"PASS: {len(rows)} data sources match the final manuscript inventory")
