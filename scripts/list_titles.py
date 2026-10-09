#!/usr/bin/env python3
"""Append `\\` to a list item's first line when indented content follows, so typst doesn't join the item's title with its contents.

Usage: list_titles.py FILE.typ...   (rewrites in place, idempotent)
"""
import re
import sys

ITEM = re.compile(r"^(\s*)(?:[-+]|\d+\.) \S")


def indent(line: str) -> int:
    return len(line) - len(line.lstrip())


def rewrite(lines: list[str]) -> list[str]:
    out = []
    in_raw = False
    for i, line in enumerate(lines):
        if line.lstrip().startswith("```"):
            in_raw = not in_raw
        nxt = lines[i + 1] if i + 1 < len(lines) else ""
        body = line.rstrip()
        if (
            not in_raw
            and (m := ITEM.match(line))
            and nxt.strip()
            and indent(nxt) > len(m.group(1))
            and not ITEM.match(nxt)  # nested list already breaks
            and not body.endswith(("\\", "[", "(", "{"))  # open code/content block spans the newline
            and body.count("$") % 2 == 0  # inside multi-line math
        ):
            line = body + "\\" + line[len(body):]
        out.append(line)
    return out


for path in sys.argv[1:]:
    with open(path) as f:
        lines = f.read().split("\n")
    new = rewrite(lines)
    if new != lines:
        with open(path, "w") as f:
            f.write("\n".join(new))
