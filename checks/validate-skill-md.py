#!/usr/bin/env python3
"""Validate SKILL.md frontmatter under a directory tree.

Walks the given path, parses YAML frontmatter from every SKILL.md found,
and asserts:

  - frontmatter is a YAML mapping
  - `name` is lowercase-with-hyphens and matches the parent folder name
  - `description` is present and non-empty

Exits 0 on success, 1 on any validation failure, 2 on usage errors.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

import yaml

NAME_RE = re.compile(r"^[a-z][a-z0-9-]*$")


def parse_frontmatter(text: str):
    if not text.startswith("---"):
        return None
    end = text.find("\n---", 3)
    if end < 0:
        return None
    return yaml.safe_load(text[3:end])


def validate(skill_md: Path) -> list[str]:
    errors: list[str] = []
    folder = skill_md.parent
    text = skill_md.read_text(encoding="utf-8")
    fm = parse_frontmatter(text)
    if fm is None:
        return [f"{skill_md}: missing or malformed YAML frontmatter"]
    if not isinstance(fm, dict):
        return [f"{skill_md}: frontmatter is not a mapping"]
    name = fm.get("name")
    if not name or not NAME_RE.match(str(name)):
        errors.append(
            f"{skill_md}: name {name!r} is not lowercase-with-hyphens"
        )
    elif name != folder.name:
        errors.append(
            f"{skill_md}: name {name!r} does not match folder {folder.name!r}"
        )
    desc = fm.get("description")
    if not desc or not str(desc).strip():
        errors.append(f"{skill_md}: description is missing or empty")
    return errors


def main(argv: list[str]) -> int:
    if len(argv) != 2:
        print("usage: validate-skill-md.py <path>", file=sys.stderr)
        return 2
    root = Path(argv[1])
    if not root.exists():
        print(f"path does not exist: {root}", file=sys.stderr)
        return 2
    errors: list[str] = []
    for skill_md in sorted(root.rglob("SKILL.md")):
        errors.extend(validate(skill_md))
    if errors:
        for err in errors:
            print(err, file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
