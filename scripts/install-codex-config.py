#!/usr/bin/env python3
"""Merge dotfiles-managed Codex defaults without replacing machine-local config."""

from __future__ import annotations

import json
import os
import re
import stat
import sys
import tempfile
from pathlib import Path

_STATUS_LINE_RE = re.compile(r"(?m)^\s*status_line\s*=\s*(\[.*\])\s*(?:#.*)?$")


def load_status_line(fragment_text: str) -> list[str]:
    """Parse tui.status_line from a managed TOML fragment without tomllib.

    Uses json for the array value so this works on Python 3.10 (no tomllib).
    """
    match = _STATUS_LINE_RE.search(fragment_text)
    if match is None:
        raise ValueError("fragment must define tui.status_line as an array of strings")
    status_line = json.loads(match.group(1))
    if not isinstance(status_line, list) or not all(isinstance(item, str) for item in status_line):
        raise ValueError("fragment must define tui.status_line as an array of strings")
    return status_line


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit(f"usage: {Path(sys.argv[0]).name} FRAGMENT TARGET")
    fragment_path, target_path = map(Path, sys.argv[1:])
    status_line = load_status_line(fragment_path.read_text(encoding="utf-8"))

    managed_line = f"status_line = {json.dumps(status_line)}"
    target_path.parent.mkdir(parents=True, exist_ok=True)
    original = target_path.read_text(encoding="utf-8") if target_path.exists() else ""
    lines = original.splitlines()
    tui_start = next((index for index, line in enumerate(lines) if re.match(r"^\s*\[tui\]\s*(?:#.*)?$", line)), None)

    if tui_start is None:
        if lines and lines[-1].strip():
            lines.append("")
        lines.extend(["[tui]", managed_line])
    else:
        tui_end = next(
            (index for index in range(tui_start + 1, len(lines)) if re.match(r"^\s*\[", lines[index])),
            len(lines),
        )
        status_index = next(
            (
                index
                for index in range(tui_start + 1, tui_end)
                if re.match(r"^\s*status_line\s*=", lines[index])
            ),
            None,
        )
        if status_index is None:
            lines.insert(tui_end, managed_line)
        else:
            lines[status_index] = managed_line

    merged = "\n".join(lines) + "\n"
    if merged == original:
        print(f"OK:   {target_path} already contains managed Codex defaults")
        return

    with tempfile.NamedTemporaryFile("w", encoding="utf-8", dir=target_path.parent, delete=False) as handle:
        handle.write(merged)
        temporary_path = Path(handle.name)
    if target_path.exists():
        os.chmod(temporary_path, stat.S_IMODE(target_path.stat().st_mode))
    os.replace(temporary_path, target_path)
    print(f"MERGE: {target_path} <- {fragment_path}")


if __name__ == "__main__":
    main()
