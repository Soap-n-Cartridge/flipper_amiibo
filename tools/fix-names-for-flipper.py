#!/usr/bin/env python3
"""Rename folders/files so Flipper Zero (official FW FatFS, CP850) can keep LFNs.

Same behavior as fix-names-for-flipper.ps1. Dry-run by default; pass --apply to rename.

Example:
  python3 tools/fix-names-for-flipper.py "/path/to/Amiibo Full Set"
  python3 tools/fix-names-for-flipper.py "/path/to/apps_data/flipper_amiibo/db" --apply
"""

from __future__ import annotations

import argparse
import os
import sys
import unicodedata
from pathlib import Path

_PUNCT = {
    "\u2018": "'",
    "\u2019": "'",
    "\u201a": "'",
    "\u201b": "'",
    "\u2032": "'",
    "\u02bc": "'",
    "\u201c": '"',
    "\u201d": '"',
    "\u2013": "-",
    "\u2014": "-",
    "\u2212": "-",
    "\u00a0": " ",
    "\u202f": " ",
    "\u2009": " ",
}


def flipper_safe_name(name: str) -> str:
    out = "".join(_PUNCT.get(ch, ch) for ch in name)
    out = unicodedata.normalize("NFKD", out)
    chars: list[str] = []
    for ch in out:
        if unicodedata.combining(ch):
            continue
        o = ord(ch)
        if 0x20 <= o <= 0x7E:
            chars.append(ch)
        else:
            chars.append("_")
    s = "".join(chars)
    while "  " in s:
        s = s.replace("  ", " ")
    s = s.strip(" .")
    return s or "unnamed"


def unique_name(directory: Path, desired: str, current: Path) -> str:
    candidate = desired
    n = 2
    while True:
        full = directory / candidate
        if not full.exists():
            return candidate
        try:
            if full.resolve() == current.resolve():
                return candidate
        except OSError:
            pass
        stem = Path(desired).stem
        suffix = Path(desired).suffix
        candidate = f"{stem} ({n}){suffix}"
        n += 1


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("path", type=Path, help="Root folder to walk")
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Actually rename (default is dry-run)",
    )
    args = parser.parse_args()
    root = args.path.expanduser().resolve()
    if not root.is_dir():
        print(f"Not a folder: {root}", file=sys.stderr)
        return 1

    print(f"Root: {root}")
    print("Mode: APPLY (renaming)" if args.apply else "Mode: dry-run (pass --apply to rename)")
    print()

    items = sorted(root.rglob("*"), key=lambda p: len(str(p)), reverse=True)
    planned = changed = skipped = 0
    for item in items:
        if item.name in (".", ".."):
            continue
        new_name = flipper_safe_name(item.name)
        if new_name == item.name:
            skipped += 1
            continue
        unique = unique_name(item.parent, new_name, item)
        planned += 1
        kind = "DIR " if item.is_dir() else "FILE"
        print(f"{kind}  {item}")
        print(f"      -> {unique}")
        if args.apply:
            item.rename(item.parent / unique)
            changed += 1

    print()
    print(f"Would change / changed: {planned} / {changed}  |  already safe: {skipped}")
    if not args.apply and planned:
        print("Re-run with --apply to perform renames, then copy/sync to the Flipper SD.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
