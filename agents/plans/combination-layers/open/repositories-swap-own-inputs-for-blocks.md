---
title: Repositories swap their own inputs for blocks
state: proposed
kind: implementation
part-of: combinations-layered-from-building-blocks
needs: [export-building-block-combinations]
---

# Repositories swap their own inputs for blocks

- The 6 repositories that add a `python-skills` input for `python-hygiene-functional-style` take the `python` block instead and drop the input: agentree-statusline, jellyfin-settings, nix-github-actions-cache-bench, nix-jetbrains-project-setup, orbstack-machine-nixos-flakes and github-config.
- github-config drops its 2 picks that `base` already holds: `questions-as-first-class-prompts` and `route-feedback-to-skills-over-memory`.

Each is a flake edit plus a lock.
