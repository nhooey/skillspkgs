---
title: Combination layers migration waves
state: proposed
kind: schedule
cost: to be estimated against the weekly limit, which the user gives
---

# Combination layers migration waves

- **PR 1, skillspkgs:** [the export](export-building-block-combinations.md) and [the families' composition](families-compose-building-blocks.md), and [the retirement of the authoring combinations](retire-authoring-combinations.md) if agreed. No pack bump is needed, unless `skill-authoring-skills` becomes an input.
- **PR 2, skillspkgs:** its own `skills-devshell` lock, which can only point at PR 1 once merged.
- **Wave A, required, 23 PRs, any order, one per repository:** the other 4 packaging repositories and the 19 collections, as [the narrowed collections](skill-repositories-take-narrowed-collections.md). Each is a lock bump; 7 also add the `python` block. Nothing changes for a repository until its own bump, so no repository loses a skill in between.
- **Wave B, optional, 6 PRs:** [the swap of own inputs for blocks](repositories-swap-own-inputs-for-blocks.md). Flake edit plus lock.
- **Wave C, optional, 5 PRs:** [the hand-written dev shells](hand-written-devshells-adopt-combinations.md).
- **No bump needed:** the 13 repositories in `nix-tooling`, `claude-code-tools`, `applications`, `configuration` and browser extensions with no change, since their family content is identical.
- **Total:** 25 required PRs, up to 36.
