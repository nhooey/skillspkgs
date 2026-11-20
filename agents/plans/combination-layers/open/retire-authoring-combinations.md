---
title: Retire the authoring combinations
state: proposed
kind: implementation
part-of: combinations-layered-from-building-blocks
needs: [export-building-block-combinations]
touches: [sources/combinations/authoring.nix, sources/combinations/authoring-with-git.nix]
---

# Retire the authoring combinations

Remove `authoring.nix` and `authoring-with-git.nix` after re-checking that no `.nix` file at any repository's `origin/master` consumes them. The [survey](../../../reports/2026-11-20-skills-devshell-survey.md) found none.
