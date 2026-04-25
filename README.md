# skillpkgs

[![Built with Garnix](https://img.shields.io/endpoint?url=https%3A%2F%2Fgarnix.io%2Fapi%2Fbadges%2Fnhooey%2Fskillspkgs&label=Garnix)](https://garnix.io/repo/nhooey/skillspkgs)

Library and curated collection for packaging [Claude Code Agent Skills](https://docs.claude.com/) as Nix flakes.

## Quick start

Initialise a new skills repo from the bundled template:

```bash
nix flake init -t github:nhooey/skillspkgs
```

You get a 10-line `flake.nix`, an `skills/example-skill/` placeholder, and a README:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    skillpkgs.url = "github:nhooey/skillspkgs";
  };
  outputs = inputs: inputs.skillpkgs.lib.mkSkillsFlake {
    inherit inputs;
    src = ./.;
  };
}
```

Drop your skills under `./skills/<name>/SKILL.md`, then `nix build` and
`nix run .#install` to copy them into `~/.claude/skills`.

## What this is

skillpkgs is shaped like a tiny `nixpkgs`: it ships both a **library** for
turning a directory of Agent Skills into a Nix flake, and a **collection**
of wrappers around third-party skills hosted upstream.

- **`lib/`** — `mkSkill`, `mkSkillsFlake`, `discoverSkills`. Used by your
  repo and by skillpkgs itself.
- **`pkgs/`** — wrappers for third-party skills. Each wrapper vendors only
  metadata (URL + rev + sha256), not source.
- **`modules/`** — home-manager and (stub) NixOS modules.
- **`templates/`** — the `nix flake init` starting point.
- **`checks/`** — the SKILL.md frontmatter validator.

## Using the library

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    skillpkgs.url = "github:nhooey/skillspkgs";
  };
  outputs = inputs: inputs.skillpkgs.lib.mkSkillsFlake {
    inherit inputs;
    src = ./.;
  };
}
```

This auto-discovers every folder containing a `SKILL.md` under `./skills/`,
builds them, and exposes:

- `packages.<system>.<skill-name>` — one derivation per skill.
- `packages.<system>.default` — `symlinkJoin` of the whole set.
- `apps.<system>.install` — copy the bundle into `~/.claude/skills` (or `$1`).
- `checks.<system>.skills-valid` — runs the SKILL.md validator.
- `homeManagerModules.default` — see below.

A skill folder can ship an optional `skill.nix` sidecar to declare runtime
dependencies for any helper scripts in `scripts/`:

```nix
{ pkgs, ... }:
{
  runtimeInputs = [ pkgs.jq pkgs.curl ];
}
```

## Using the collection

```nix
inputs.skillpkgs.url = "github:nhooey/skillspkgs";
# ...
environment.systemPackages = [ inputs.skillpkgs.packages.${system}.default ];
```

Or pull a single wrapper: `inputs.skillpkgs.packages.${system}.<skill-name>`.

## Adding a third-party skill to the collection

See [`pkgs/README.md`](./pkgs/README.md) for the contributor checklist
(folder layout, what `default.nix` should look like, the metadata-only
vendoring rule, and how to compute the sha256).

## Why copy, not symlink

Claude Code reads skill files directly from `~/.claude/skills/<name>/` and
does not follow symlinks across the skill boundary — symlinked installs
surface as missing or unreadable skills. So both `apps.install` and the
home-manager activation copy the bundle into place rather than symlinking
it. The cost is a few hundred kilobytes per skill, duplicated across
generations. The benefit is that skills actually load.

## CI

[Garnix](https://garnix.io) is the gating CI for this repo. Configuration
lives in [`garnix.yaml`](./garnix.yaml) and currently builds:

- `packages.{x86_64,aarch64}-linux.*` — every wrapper plus the bundled `default`.
- `checks.{x86_64,aarch64}-linux.*` — the SKILL.md validator against `examples/basic`.
- `devShells.{x86_64,aarch64}-linux.default` — keeps the contributor shell evaluable.
- `homeManagerModules.default` — eval-only, catches type errors in the module.

Garnix has no Darwin builders, so Darwin attrs are deliberately excluded;
they still evaluate locally via `nix flake check` on a Mac.

To enable Garnix on a fork, install the [Garnix GitHub app](https://garnix.io)
on the repository and (recommended) add a branch protection rule on `main`
requiring the `garnix` status check to pass before merge.
