#!/usr/bin/env python3
"""Install the MonsterCofferHelper addon into the local ESO AddOns directory.

Works on Windows (native ESO) and Linux (ESO via Steam Proton / Lutris Wine).

Usage:
    py -3 install.py            # Windows
    python3 install.py          # Linux
    python3 install.py --dest "/path/to/live/AddOns"   # explicit AddOns dir
    python3 install.py --dry-run

You can also set the ESO_ADDONS_DIR environment variable to point at the
"live/AddOns" directory to skip auto-detection.
"""
from __future__ import annotations

import argparse
import os
import re
import shutil
import sys
from pathlib import Path

ADDON_NAME = "MonsterCofferHelper"


def source_dir() -> Path:
    """The addon folder that sits next to this script."""
    src = Path(__file__).resolve().parent / ADDON_NAME
    if not (src / f"{ADDON_NAME}.txt").is_file():
        sys.exit(f"error: could not find addon manifest at {src / (ADDON_NAME + '.txt')}")
    return src


def candidate_addons_dirs() -> list[Path]:
    """Likely 'live/AddOns' locations, most-specific first, per platform."""
    home = Path.home()
    docs_tail = Path("Elder Scrolls Online") / "live" / "AddOns"
    candidates: list[Path] = []

    if os.name == "nt":
        # Native Windows install: Documents may be redirected (e.g. OneDrive).
        userprofile = Path(os.environ.get("USERPROFILE", home))
        for docs in (userprofile / "Documents", userprofile / "OneDrive" / "Documents", home / "Documents"):
            candidates.append(docs / docs_tail)
    else:
        # ESO on Linux runs under Wine/Proton; Documents lives inside the prefix.
        wine_tail = Path("drive_c") / "users" / "steamuser" / "Documents" / docs_tail
        # Steam Proton default appid for ESO is 306130.
        steam_roots = [
            home / ".steam" / "steam" / "steamapps" / "compatdata",
            home / ".local" / "share" / "Steam" / "steamapps" / "compatdata",
        ]
        for root in steam_roots:
            if root.is_dir():
                # Search all prefixes; the ESO one (306130) first if present.
                appids = sorted(root.iterdir(), key=lambda p: (p.name != "306130", p.name))
                for appid in appids:
                    candidates.append(appid / "pfx" / wine_tail)
        # Lutris / plain Wine prefixes.
        for prefix in (
            home / "Games" / "the-elder-scrolls-online",
            home / ".wine",
        ):
            candidates.append(prefix / "drive_c" / "users" / os.environ.get("USER", "user")
                              / "Documents" / docs_tail)
            candidates.append(prefix / "drive_c" / "users" / "steamuser" / "Documents" / docs_tail)

    return candidates


def resolve_dest(explicit: str | None) -> Path:
    if explicit:
        return Path(explicit).expanduser()
    env = os.environ.get("ESO_ADDONS_DIR")
    if env:
        return Path(env).expanduser()

    for cand in candidate_addons_dirs():
        # Prefer a location whose parent already exists (ESO has been run there).
        if cand.parent.is_dir():
            return cand

    sys.exit(
        "error: could not auto-detect the ESO 'live/AddOns' directory.\n"
        "       Pass it explicitly with --dest or set ESO_ADDONS_DIR.\n"
        "       Example (Windows):\n"
        '         py -3 install.py --dest "C:\\Users\\you\\Documents\\Elder Scrolls Online\\live\\AddOns"'
    )


def manifest_dependencies(src: Path) -> tuple[list[str], list[str]]:
    """Read DependsOn / OptionalDependsOn out of the manifest.

    Parsed rather than hardcoded so this check cannot drift from the manifest.
    Version suffixes such as 'LibAddonMenu-2.0>=41' are stripped; only presence
    is checked, since the game itself enforces versions.
    """
    required: list[str] = []
    optional: list[str] = []

    for line in (src / f"{ADDON_NAME}.txt").read_text(encoding="utf-8").splitlines():
        match = re.match(r"^##\s*(Optional)?DependsOn:\s*(.+)$", line.strip())
        if not match:
            continue
        names = [re.split(r"[<>=]", token)[0] for token in match.group(2).split()]
        (optional if match.group(1) else required).extend(name for name in names if name)

    return required, optional


def report_dependencies(addons_dir: Path, required: list[str], optional: list[str]) -> None:
    """Warn about libraries the addon needs that are not installed alongside it."""
    def missing(names: list[str]) -> list[str]:
        return [name for name in names if not (addons_dir / name).is_dir()]

    missing_required = missing(required)
    missing_optional = missing(optional)

    if missing_required:
        print(f"WARNING: required library not installed: {', '.join(missing_required)}")
        print("         The addon will not load until it is present.")
    if missing_optional:
        print(f"Note: optional library not installed: {', '.join(missing_optional)}")

    if not missing_required and not missing_optional and (required or optional):
        print(f"Dependencies present: {', '.join(required + optional)}")


def main() -> None:
    parser = argparse.ArgumentParser(description=f"Install the {ADDON_NAME} ESO addon locally.")
    parser.add_argument("--dest", help="Path to the ESO 'live/AddOns' directory.")
    parser.add_argument("--dry-run", action="store_true", help="Show what would happen without copying.")
    args = parser.parse_args()

    src = source_dir()
    addons_dir = resolve_dest(args.dest)
    dest = addons_dir / ADDON_NAME

    print(f"Source: {src}")
    print(f"Target: {dest}")

    # Replacing the target means deleting it first, so make sure it is really a
    # previous install of this addon and not some unrelated folder a mistyped
    # --dest happened to land on.
    if dest.exists():
        if not dest.is_dir():
            sys.exit(f"error: {dest} exists and is not a directory.")
        if not (dest / f"{ADDON_NAME}.txt").is_file():
            sys.exit(
                f"error: {dest} exists but holds no {ADDON_NAME}.txt manifest.\n"
                "       Refusing to delete it. Remove it by hand if it really is stale."
            )
        print("Replacing the existing install.")

    if args.dry_run:
        if addons_dir.is_dir():
            required, optional = manifest_dependencies(src)
            report_dependencies(addons_dir, required, optional)
        print("(dry run) nothing copied.")
        return

    addons_dir.mkdir(parents=True, exist_ok=True)
    if dest.exists():
        shutil.rmtree(dest)
    shutil.copytree(src, dest)
    print(f"Installed {ADDON_NAME} -> {dest}")

    required, optional = manifest_dependencies(src)
    report_dependencies(addons_dir, required, optional)


if __name__ == "__main__":
    main()
