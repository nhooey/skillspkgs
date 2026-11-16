# skillspkgs

A Nix aggregator for agent skills. `pkgs/` wraps third-party skill repositories that ship no flake, `sources/aggregated/` merges the first-party skill repositories that do, and `sources/combinations/` defines curated unions of both, among them one combination per repository family in `families.nix`. The build and install logic lives in `nhooey/agent-skill-flake`. `scripts/bump-skills-chain` moves skill repositories to their newest commits here and downstream.

## Build and test

- `nix develop`: the dev shell, with the `check`, `fmt` and `update-flake` commands, and the project's skills installed into `.agents/skills/` from the `skills-devshell/` sub-flake.
- `nix flake check`: builds every combination and every aggregated skill, checks that the root and `sources/aggregated/` locks pin the same revisions, runs the home-manager module's activation script against fake skills (`tests/home-manager-module.nix`), lints `scripts/bump-skills-chain` and runs its bats tests (`tests/bump-skills-chain.bats`), and fails on any file `nix fmt` would change.
- `nix fmt`: formats every file.
