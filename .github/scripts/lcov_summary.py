#!/usr/bin/env python3
"""Markdown summary of an lcov file for the CI job page ($GITHUB_STEP_SUMMARY).

Usage: lcov_summary.py <lcov.info>

Prints the total line coverage and the coverage per area: lib/app, lib/core and each
lib/features/<feature>.
"""

from __future__ import annotations

import sys
from collections import defaultdict
from pathlib import Path


def area(source: str) -> str:
    parts = Path(source).parts
    if "lib" not in parts:
        return source
    rest = parts[parts.index("lib") + 1 :]
    if len(rest) >= 2 and rest[0] == "features":
        return f"features/{rest[1]}"
    return rest[0] if len(rest) > 1 else "(lib root)"


def pct(hit: int, found: int) -> str:
    return f"{100 * hit / found:.1f} %" if found else "n/a"


def main(argv: list[str]) -> int:
    if len(argv) != 1:
        print(__doc__, file=sys.stderr)
        return 2
    report = Path(argv[0])
    if not report.exists():
        print(f"## Coverage\n\nNo lcov report at `{report}`.\n")
        return 0
    totals: dict[str, list[int]] = defaultdict(lambda: [0, 0])
    current = ""
    files = 0
    for line in report.read_text(encoding="utf-8").splitlines():
        if line.startswith("SF:"):
            current = area(line[3:])
            files += 1
        elif line.startswith("LF:"):
            totals[current][1] += int(line[3:])
        elif line.startswith("LH:"):
            totals[current][0] += int(line[3:])
    hit = sum(h for h, _ in totals.values())
    found = sum(f for _, f in totals.values())
    print("## Coverage")
    print()
    print(f"**{pct(hit, found)}** of lines ({hit} / {found}) in {files} files.")
    print()
    print("| Area | Lines | Coverage |")
    print("|---|---:|---:|")
    for name in sorted(totals):
        h, f = totals[name]
        print(f"| `{name}` | {h} / {f} | {pct(h, f)} |")
    print()
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
