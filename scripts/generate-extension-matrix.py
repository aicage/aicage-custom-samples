#!/usr/bin/env python3
import json
import sys
from pathlib import Path


def main() -> int:
    if len(sys.argv) != 3:
        print(
            "Usage: scripts/generate-extension-matrix.py <distros-json> <excluded-json>",
            file=sys.stderr,
        )
        return 1

    try:
        distros = json.loads(sys.argv[1])
    except json.JSONDecodeError as exc:
        print(f"Invalid distros JSON: {exc}", file=sys.stderr)
        return 1

    try:
        excluded_json = json.loads(sys.argv[2])
    except json.JSONDecodeError as exc:
        print(f"Invalid excluded JSON: {exc}", file=sys.stderr)
        return 1

    if not isinstance(distros, dict) or not distros:
        print("Distros JSON must be a non-empty object", file=sys.stderr)
        return 1

    if not isinstance(excluded_json, list):
        print("Excluded JSON must be a list", file=sys.stderr)
        return 1

    extensions = sorted(
        path.name for path in Path("extensions").iterdir() if path.is_dir()
    )
    excluded = {tuple(item) for item in excluded_json}

    matrix = []
    for extension in extensions:
        for distro, from_image in distros.items():
            if (extension, distro) in excluded:
                continue
            matrix.append(
                {
                    "extension": extension,
                    "distro": distro,
                    "from_image": from_image,
                }
            )

    print(json.dumps({"include": matrix}, separators=(",", ":")))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
