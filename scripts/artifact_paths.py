"""Resolve paths recorded inside test_vectors/ artifacts against this checkout.

Harnesses record absolute paths from whichever checkout captured them, so
checked-in artifacts point at directories that do not exist anywhere else.
Paths that run through a top-level repo directory are mapped back onto ROOT.
"""

from __future__ import annotations

import pathlib


ROOT = pathlib.Path(__file__).resolve().parents[1]
REPO_DIRS = ("test_vectors", "scripts", "docker", "rust", "packages")


def repo_path(value: str | pathlib.Path) -> pathlib.Path:
    path = pathlib.Path(value)
    if not path.is_absolute() or path.is_relative_to(ROOT):
        return path
    parts = path.parts
    candidates = [
        ROOT.joinpath(*parts[index:])
        for index, part in enumerate(parts)
        if part in REPO_DIRS
    ]
    for candidate in candidates:
        if candidate.exists():
            return candidate
    return candidates[-1] if candidates else path
