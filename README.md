# skillpkgs

[![Built with Garnix](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Fgarnix.io%2Fapi%2Fbadges%2Fnhooey%2Fskillspkgs)](https://garnix.io/repo/nhooey/skillspkgs)

Directory of per-skill flake wrappers around third-party [Claude Code Agent Skills](https://docs.claude.com/) hosted in upstream repositories that don't ship Nix flakes themselves.

Each subdirectory under `pkgs/` is a thin wrapper that:

- pins an upstream repo by `(owner, rev, hash)`,
- delegates the actual skill build + install/uninstall/preview/reap apps to [`nhooey/flake-skills`](https://github.com/nhooey/flake-skills) via `lib.mkSkillFlake`,
- can be installed independently as a standalone flake, no aggregation step required.

For first-party skill content (skills you author yourself), use [`nhooey/skills-nix`](https://github.com/nhooey/skills-nix) as a reference, or `nix flake init -t github:nhooey/skillspkgs` to scaffold a new first-party-skills repo using `flake-skills.lib.mkAllSkillsFlake`. **This** repo is intentionally for wrappers only.

## Quick start — install one skill

```bash
nix run github:nhooey/skillspkgs?dir=pkgs/humanizer#install
```

That symlinks the skill into `~/.claude/skills/humanizer/`, registers a per-user GC root so the store path won't be garbage-collected, and writes an entry into `~/.claude/skills/.flake-skills-lock.json`. Other apps available per skill (from `flake-skills`):

```bash
nix run github:nhooey/skillspkgs?dir=pkgs/humanizer            # preview (read-only, default)
nix run github:nhooey/skillspkgs?dir=pkgs/humanizer#install    # install (symlink + GC root)
nix run github:nhooey/skillspkgs?dir=pkgs/humanizer#install -- --profile  # via nix profile
nix run github:nhooey/skillspkgs?dir=pkgs/humanizer#uninstall  # remove
nix run github:nhooey/skillspkgs?dir=pkgs/humanizer#reap       # clean up dead managed entries
nix build github:nhooey/skillspkgs?dir=pkgs/humanizer          # produce ./result
```

## Quick start — declarative install via home-manager

```nix
{
  inputs = {
    skillpkgs.url = "github:nhooey/skillspkgs";
    humanizer.url = "github:nhooey/skillspkgs?dir=pkgs/humanizer";
  };
  outputs = { skillpkgs, humanizer, ... }: {
    homeConfigurations.<name> = home-manager.lib.homeManagerConfiguration {
      modules = [
        skillpkgs.homeManagerModules.default
        ({ pkgs, ... }: {
          programs.agent-skills = {
            enable = true;
            skills = [
              humanizer.packages.${pkgs.system}.default
            ];
          };
        })
      ];
    };
  };
}
```

The home-manager module symlinks every skill listed in `programs.agent-skills.skills` into `programs.agent-skills.target` (default `~/.claude/skills`).

## What this repo is for

A wrapper layer for **upstream** skill projects whose authors don't (yet) ship a flake themselves and won't accept a Nix-related PR. The wrappers vendor only metadata — `(github:<owner>/<repo>, rev, hash)` — and `flake-skills` does the actual derivation work.

PRs that fall outside that charter get closed. See [`pkgs/README.md`](./pkgs/README.md).

## How it relates to other repos

- **[`nhooey/flake-skills`](https://github.com/nhooey/flake-skills)** — the library. Provides `mkSkillFlake` and `mkAllSkillsFlake`. Both `skillspkgs` (this repo) and `skills-nix` consume it.
- **[`nhooey/skills-nix`](https://github.com/nhooey/skills-nix)** — first-party skill content the author maintains. Uses `mkAllSkillsFlake`.
- **`nhooey/skillspkgs`** (this repo) — third-party wrappers. Each `pkgs/<name>/flake.nix` calls `mkSkillFlake` with `src` pointing at a `fetchFromGitHub` flake input.

## Adding a wrapper

See [`pkgs/README.md`](./pkgs/README.md). The template is a ~20-line `flake.nix` per wrapper.

## CI

[Garnix](https://garnix.io) builds the root flake's `devShells.default` and evaluates `homeManagerModules.default` on `x86_64-linux` and `aarch64-linux`. Per-skill flakes are not currently covered by CI here — they'd need a separate Garnix configuration per `?dir=...` URL. Contributions welcome.
