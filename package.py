#!/usr/bin/env python3
"""Package the addon into a zip ready for upload to ESOUI.

The archive holds a single top-level MonsterCofferHelper/ folder, which is the
shape ESO's AddOns directory expects, so users can extract it straight there.
It is named after the ## Version in the manifest, so a file sitting on disk
always says which build it is.

Usage:
    py -3 package.py                    # -> dist/MonsterCofferHelper-1.0.0.zip
    py -3 package.py --out-dir .        # write it somewhere else
    py -3 package.py --dry-run          # list the contents, write nothing
"""
from __future__ import annotations

import argparse
import re
import sys
import zipfile
from pathlib import Path

ADDON_NAME = "MonsterCofferHelper"
ROOT = Path(__file__).resolve().parent

# Working files that have no business in a release. Anything the game itself
# would ignore is still worth leaving out: the zip is what users judge.
EXCLUDED_DIRS = {".git", "__pycache__"}
EXCLUDED_NAMES = {".DS_Store", "Thumbs.db", "desktop.ini"}
EXCLUDED_SUFFIXES = {".bak", ".orig", ".rej", ".swp", ".zip"}


def source_dir() -> Path:
    """The addon folder that sits next to this script."""
    src = ROOT / ADDON_NAME
    if not (src / f"{ADDON_NAME}.txt").is_file():
        sys.exit(f"error: could not find addon manifest at {src / (ADDON_NAME + '.txt')}")
    return src


def manifest_lines(src: Path) -> list[str]:
    return (src / f"{ADDON_NAME}.txt").read_text(encoding="utf-8").splitlines()


def manifest_version(src: Path) -> str:
    """The ## Version directive, which names the archive.

    Read rather than passed in so the zip name cannot drift from what the game
    and ESOUI will report once it is installed.
    """
    for line in manifest_lines(src):
        match = re.match(r"^##\s*Version:\s*(.+?)\s*$", line.strip())
        if match:
            return match.group(1)
    sys.exit(f"error: no '## Version:' line in {ADDON_NAME}.txt; cannot name the archive.")


def missing_manifest_files(src: Path) -> list[str]:
    """Files the manifest loads that are not actually there.

    A release that ships a manifest entry with no file behind it throws an error
    in every user's client on load, so it is worth catching here rather than in
    the bug reports.
    """
    missing = []
    for line in manifest_lines(src):
        entry = line.strip()
        # Directives start with ##, comments with #; everything else is a path.
        if not entry or entry.startswith("#"):
            continue
        relative = entry.replace("\\", "/")
        if "$(language)" in relative:
            # ESO substitutes the client language at load time; any match will do.
            if not list(src.glob(relative.replace("$(language)", "*"))):
                missing.append(entry)
        elif not (src / relative).is_file():
            missing.append(entry)
    return missing


def payload(src: Path) -> list[tuple[Path, str]]:
    """(file on disk, name inside the zip) pairs, sorted so the archive is stable."""
    items: list[tuple[Path, str]] = []

    for path in sorted(src.rglob("*")):
        if not path.is_file():
            continue
        relative = path.relative_to(src)
        if set(relative.parts) & EXCLUDED_DIRS:
            continue
        if path.name in EXCLUDED_NAMES or path.suffix.lower() in EXCLUDED_SUFFIXES:
            continue
        items.append((path, f"{ADDON_NAME}/{relative.as_posix()}"))

    # The GPL asks that the licence travel with the distributed form, and the
    # repo root is not part of what gets installed, so fold it into the folder.
    licence = ROOT / "LICENSE"
    if licence.is_file():
        items.append((licence, f"{ADDON_NAME}/LICENSE"))
    else:
        print("WARNING: no LICENSE at the repo root; the archive will ship without one.")

    return items


def main() -> None:
    parser = argparse.ArgumentParser(description=f"Build a release zip of the {ADDON_NAME} addon.")
    parser.add_argument("--out-dir", default="dist", help="Where to write the archive (default: dist).")
    parser.add_argument("--dry-run", action="store_true", help="List what would go in without writing it.")
    args = parser.parse_args()

    src = source_dir()
    version = manifest_version(src)

    missing = missing_manifest_files(src)
    if missing:
        print("error: the manifest loads files that do not exist:")
        for entry in missing:
            print(f"       {entry}")
        sys.exit(1)

    # Version strings are author-controlled and end up in a filename.
    archive = Path(args.out_dir).expanduser() / f"{ADDON_NAME}-{re.sub(r'[^A-Za-z0-9._-]', '-', version)}.zip"
    items = payload(src)

    print(f"Version: {version}")
    print(f"Archive: {archive}")
    for _, name in items:
        print(f"  {name}")

    if args.dry_run:
        print("(dry run) nothing written.")
        return

    archive.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(archive, "w", zipfile.ZIP_DEFLATED) as bundle:
        for path, name in items:
            bundle.write(path, name)

    print(f"\nWrote {archive} ({archive.stat().st_size:,} bytes, {len(items)} files)")


if __name__ == "__main__":
    main()
