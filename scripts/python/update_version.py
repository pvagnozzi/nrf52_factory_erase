#!/usr/bin/env python3
"""Update major/minor/build in version.properties from CLI arguments.

Usage:
    python update_version.py <major> <minor> <build>

Example:
    python update_version.py 1 2 5
"""

import sys


def main() -> None:
    if len(sys.argv) != 4:  # noqa: PLR2004
        print(f"Usage: {sys.argv[0]} <major> <minor> <build>", file=sys.stderr)
        sys.exit(1)

    major, minor, build = sys.argv[1], sys.argv[2], sys.argv[3]

    with open("version.properties", "r", encoding="utf-8") as f:
        lines = f.readlines()

    with open("version.properties", "w", encoding="utf-8") as f:
        for line in lines:
            stripped = line.lstrip()
            if stripped.startswith("major"):
                f.write(f"major = {major}\n")
            elif stripped.startswith("minor"):
                f.write(f"minor = {minor}\n")
            elif stripped.startswith("build"):
                f.write(f"build = {build}\n")
            else:
                f.write(line)

    print(f"✔  version.properties updated → {major}.{minor}.{build}")


if __name__ == "__main__":
    main()
