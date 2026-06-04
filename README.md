# skillspkgs

[![Built with Garnix](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Fgarnix.io%2Fapi%2Fbadges%2Fnhooey%2Fskillspkgs)](https://garnix.io/repo/nhooey/skillspkgs)

A Nix aggregator for [Claude Code Agent Skills](https://docs.claude.com/), packaged across three categories:

1. **Vendored third-party skills** (`pkgs/`) — upstream repos that don't ship a Nix flake, wrapped here.
2. **Aggregated first-party repos** (`sources/aggregated/`) — `nhooey` repos that ship their own flake, merged in.
3. **Combinations** (`sources/combinations/`) — curated unions of skills already provided by (1) and (2).

The build/install/uninstall/preview/reap logic lives in [`nhooey/flake-skills`](https://github.com/nhooey/flake-skills); this repo wires it together.

## Category 1 — vendored third-party wrappers (`pkgs/`)

Each subdirectory under `pkgs/` is a thin wrapper that:

- pins an upstream repo whose authors don't ship a Nix flake,
- delegates the skill build + install/uninstall/preview/reap apps to `flake-skills` via `lib.mkSkillFlake`,
- can be installed independently as a standalone flake — no aggregation step required.

See [`pkgs/README.md`](./pkgs/README.md) for the wrapper charter, the ~20-line `flake.nix` template, and pinning rules. That subdirectory is wrappers-only; PRs adding first-party content, forks, or multi-skill bundles there get closed.

### Quick start — install one skill

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

### Quick start — declarative install via home-manager

```nix
{
  inputs = {
    skillspkgs.url = "github:nhooey/skillspkgs";
    humanizer.url = "github:nhooey/skillspkgs?dir=pkgs/humanizer";
  };
  outputs = { skillspkgs, humanizer, ... }: {
    homeConfigurations.<name> = home-manager.lib.homeManagerConfiguration {
      modules = [
        skillspkgs.homeManagerModules.default
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

## Category 2 — aggregated first-party repos (`sources/aggregated/`)

Unlike category 1, these are `nhooey` repos that **ship their own Nix flake**. skillspkgs aggregates them by merging each repo's `packages` / `legacyPackages` into its own outputs, so that

```bash
nix run github:nhooey/skillspkgs#<name>
```

works for any package any aggregated repo exposes. Name collisions are last-write-wins; rename in the source repo to disambiguate.

### Adding an aggregated repo

Every flake **input** that isn't listed in `infrastructureInputs` (the inputs that power this flake itself) is treated as a downstream repo to aggregate. To add one, declare a single input block. Because there are two flakes in play (see below), **the same input must be declared in both files, kept in sync**:

- [`flake.nix`](./flake.nix) — the root flake, which does the real aggregation.
- [`sources/aggregated/flake.nix`](./sources/aggregated/flake.nix) — a standalone `?dir=sources/aggregated` face.

```nix
# in BOTH flake.nix and sources/aggregated/flake.nix
<repo-name> = {
  url = "github:nhooey/<repo-name>";
  inputs.nixpkgs.follows = "nixpkgs";
  # Add `inputs.flake-skills.follows = "flake-skills";` only if the repo
  # depends on flake-skills — it keeps every repo on one flake-skills rev so
  # consumers don't see multiple flake-skills nodes drift apart in their lock.
};
```

`nix-gstack` is an example of an aggregated input that does **not** follow `flake-skills` (it doesn't depend on it); `coding-agent-skills`, `skills-git`, and `skills-nix` do.

After editing, run `nix flake lock` in each directory so both `flake.lock` files pin the new input.

### Why the input is declared twice

The root flake never reads the sub-flake's `flake.nix`. It plain-`import`s `sources/aggregated/default.nix` and passes its own (much larger) input set. The sub-flake under `sources/aggregated/` exists only to give that subpath a standalone, buildable `?dir=sources/aggregated` face, so it re-declares the category-2 repos explicitly. Each flake therefore needs its own copy of the input.

The root uses plain `import` rather than `path:` / `?dir=` sub-flake inputs because Garnix's evaluator rejects `path:` flake inputs when this flake is consumed transitively (e.g. from `nur-packages`). The standalone sub-flakes remain on disk purely for direct `github:nhooey/skillspkgs?dir=<path>` consumption.

## Category 3 — combinations (`sources/combinations/`)

Curated unions of skills already provided by categories 1 and 2, built via `flake-skills.lib.mkCombination` in `sources/combinations/<name>.nix`. Each combination is exposed under its own `combinations.<name>` output and is deliberately kept **out** of `packages.<sys>`. Other repos can import a combination directly, or use it as a `{ source = …; }` member of a larger combination.

## How it relates to other repos

- **[`nhooey/flake-skills`](https://github.com/nhooey/flake-skills)** — the library. Provides `mkSkillFlake`, `mkAllSkillsFlake`, `mkAggregateSkillsFlake`, `mkCombination`, and `mkSkillsEnv`. Consumed by this repo and by the first-party content repos.
- **[`nhooey/skills-nix`](https://github.com/nhooey/skills-nix)** — first-party skill content the author maintains, using `mkAllSkillsFlake`. A good reference for authoring your own skills repo; `nix flake init -t github:nhooey/skillspkgs` scaffolds one.
- **`nhooey/skillspkgs`** (this repo) — aggregates all three categories above.

## CI

[Garnix](https://garnix.io) builds the root flake's `devShells.default` and evaluates `homeManagerModules.default` on `x86_64-linux` and `aarch64-linux`. Per-skill `?dir=...` flakes are not currently covered by CI here — they'd need a separate Garnix configuration per URL. Contributions welcome.
</content>
</invoke>
