---
title: Hand-written dev shells adopt combinations
state: proposed
kind: implementation
part-of: combinations-layered-from-building-blocks
needs: [export-building-block-combinations]
---

# Hand-written dev shells adopt combinations

Move the 5 repositories that predate the families to a family plus blocks: dendrometer, chrome-extension-declarative-tab-groups, nix-devshell-cached-exports, nix-worktrees and claude-in-nix-devshell.

- nix-worktrees still points at the old `skills-git` and `skills-nix` repositories.
- dendrometer uses `sources/aggregated` and takes 11 superpowers skills, so it takes `development-workflow`.
- claude-in-nix-devshell is on `origin/main` and idle since 2026-10-19.
