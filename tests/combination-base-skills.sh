# shellcheck shell=bash
# The build script of checks.combination-base-skills in flake.nix, which
# sets $installed to the base combination's env and $expected to
# tests/combination-base-skills.txt.
: "${installed:?}" "${expected:?}" "${out:?}"
# shellcheck disable=SC2012 # skill folder names hold only letters, digits and hyphens
ls -1 "$installed/share/claude-skills" |
  LC_ALL=C sort |
  diff --unified "$expected" - ||
  exit 1
touch "$out"
