#!/usr/bin/env python3
"""Reject local paths, secrets, private data objects and oversized files."""

from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
forbidden_patterns = {
    "macOS user path": re.compile(r"/Users/[^/\s]+/"),
    "server data path": re.compile(r"(?<!https:)(?<!http:)/data/"),
    "home shortcut": re.compile(r"(?<!\w)~/"),
    "private key": re.compile(r"BEGIN (?:RSA |OPENSSH )?PRIVATE KEY"),
}
forbidden_suffixes = {
    ".fastq", ".bam", ".bai", ".h5", ".h5ad", ".loom", ".rds",
    ".rdata", ".mtx", ".svs", ".ndpi", ".ai",
}

for path in ROOT.rglob("*"):
    if not path.is_file() or ".git" in path.parts:
        continue
    if path.resolve() == Path(__file__).resolve():
        continue
    relative = path.relative_to(ROOT)
    if path.stat().st_size > 10 * 1024 * 1024:
        raise SystemExit(f"Oversized file (>10 MB): {relative}")
    if path.suffix.lower() in forbidden_suffixes:
        raise SystemExit(f"Forbidden data/binary file: {relative}")
    if path.suffix.lower() not in {
        ".py", ".r", ".md", ".yaml", ".yml", ".tsv", ".txt", ".cff", ".sh", ".lock", ""
    }:
        continue
    text = path.read_text(encoding="utf-8", errors="ignore")
    if relative == Path("config/project.example.yaml") and re.search(
        r"^\s*sample_id\s*:", text, flags=re.MULTILINE
    ):
        raise SystemExit(
            "Project example config must not contain institutional sample IDs"
        )
    for label, pattern in forbidden_patterns.items():
        if pattern.search(text):
            raise SystemExit(f"{label} found in {relative}")

print("PASS: no absolute local paths, secrets, large objects or private data files")
