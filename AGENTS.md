# skillspkgs

A Nix aggregator for agent skills. `pkgs/` wraps third-party skill repositories that ship no flake, `sources/aggregated/` merges the first-party skill repositories that do, and `sources/combinations/` defines curated unions of both, among them one combination per repository family in `families.nix`. The build and install logic lives in `nhooey/agent-skill-flake`. The dev shell's `skillspkgs` command (`scripts/skillspkgs`) bumps skill inputs here and downstream and keeps the `sources/aggregated/` lock in step; `skillspkgs --help` lists its commands.

## Build and test

- `nix develop`: the dev shell, with the `check`, `fmt`, `update-flake` and `skillspkgs` commands, and the project's skills installed into `.agents/skills/` from the `skills-devshell/` sub-flake.
- `nix flake check`: builds every combination and every aggregated skill, checks that the root and `sources/aggregated/` locks pin the same revisions, builds the dev-shell reconcile app over the aggregated skills as `sources/aggregated/`'s own check does, runs the home-manager module's activation script against fake skills (`tests/home-manager-module.nix`), lints `scripts/skillspkgs` and runs its bats tests (`tests/skillspkgs.bats`), and fails on any file `nix fmt` would change.
- `nix fmt`: formats every file.
