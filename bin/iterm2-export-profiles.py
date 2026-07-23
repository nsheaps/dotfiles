#!/usr/bin/env python3
"""Export iTerm2 profiles into custom-profiles.json for version control.

iTerm2 keeps its "regular" (non-Dynamic) profiles in the "New Bookmarks"
array of ~/Library/Preferences/com.googlecode.iterm2.plist. This script
reads that array and writes it out as the Dynamic Profiles JSON format
(a top-level {"Profiles": [...]} object) so the live profile config can be
diffed and version-controlled.

Keys are sorted alphabetically on write so re-running this after a
no-op change in iTerm2 produces a clean diff (the plist's own on-disk key
order is arbitrary and shifts between saves).

Usage:
    bin/iterm2-export-profiles
    bin/iterm2-export-profiles --plist <path> --output <path>
"""

import argparse
import json
import plistlib
import sys
from pathlib import Path

DEFAULT_PLIST = Path.home() / "Library/Preferences/com.googlecode.iterm2.plist"
REPO_ROOT = Path(__file__).resolve().parent.parent
DEFAULT_OUTPUT = REPO_ROOT / (
    "_home/Library/Application Support/iTerm2"
    "/DynamicProfiles/custom-profiles.json"
)


def export_profiles(plist_path: Path, output_path: Path) -> dict:
    """Read New Bookmarks from plist_path and write it as Dynamic Profiles JSON.

    Returns the parsed {"Profiles": [...]} dict that was written, so callers
    (and tests) can assert on it without re-reading the file from disk.
    """
    with open(plist_path, "rb") as f:
        data = plistlib.load(f)

    profiles = data.get("New Bookmarks", [])
    result = {"Profiles": profiles}

    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, "w") as f:
        json.dump(result, f, indent=2, sort_keys=True)
        f.write("\n")

    return result


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--plist",
        type=Path,
        default=DEFAULT_PLIST,
        help=f"iTerm2 prefs plist to read (default: {DEFAULT_PLIST})",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=DEFAULT_OUTPUT,
        help=f"custom-profiles.json path to write (default: {DEFAULT_OUTPUT})",
    )
    args = parser.parse_args(argv)

    if not args.plist.exists():
        print(f"error: plist not found: {args.plist}", file=sys.stderr)
        return 1

    result = export_profiles(args.plist, args.output)
    count = len(result["Profiles"])
    names = ", ".join(p.get("Name", "<unnamed>") for p in result["Profiles"])
    print(f"Exported {count} profile(s) to {args.output}: {names}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
