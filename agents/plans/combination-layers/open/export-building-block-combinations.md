---
title: Export the building blocks as combinations
state: proposed
kind: implementation
part-of: combinations-layered-from-building-blocks
touches: [sources/combinations/families.nix, sources/combinations/flake.nix, tests/]
---

# Export the building blocks as combinations

Turn the `let` bindings in `sources/combinations/families.nix` (`inputBumping`, `shippedDefaults`, `changelogs`) into `mk` combinations and export them. Add the new blocks from [the end state](combinations-layered-from-building-blocks.md): `skill-authoring`, `releases`, `github-policy`, `python`, `development-workflow` and the candidate `nix-clojure`.

- Add an expected-skills list for each block beside `tests/combination-base-skills.txt`, with a test that fails when a block's skills differ from its list.
- Check first that `mkDevshellSkillsFlake` accepts a family and a block side by side, and how it treats a duplicate.
- A test confirms that no block holds a `base` skill.

See the [survey](../../../reports/2026-11-20-skills-devshell-survey.md).
