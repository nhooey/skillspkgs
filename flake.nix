{
  description = "skillspkgs — Claude Code skills aggregator across three categories: (1) vendored third-party skills with no upstream flake, (2) first-party nhooey repos that ship their own flake, and (3) curated cross-cutting skill combinations.";

  # =====================================================================
  # Three categories of skill packages (each in its own subdir under ./sources/)
  # =====================================================================
  # Each category lives in ./sources/<cat>/: the root imports that subdir's
  # `default.nix` (plain Nix), while a sibling flake.{nix,lock} provides a
  # standalone `?dir=sources/<cat>` face. The vendored/combinations default.nix
  # auto-discover their sibling named `.nix` files, so adding a skill is mostly a
  # matter of dropping in a new file.
  # 1. VENDORED third-party skills — upstream ships no Nix flake, so we
  #    package them here from `flake = false` `*-src` inputs. Canonical build
  #    logic + pack data live under pkgs/<name>/ (also consumed standalone via
  #    `?dir=`); sources/vendored/<name>.nix assembles each. Per-skill packages
  #    land in `packages.<sys>` under `agent-skill-<name>`.
  # 2. AGGREGATED first-party repos — they ship their own flake; we merge
  #    their `packages` / `legacyPackages` in (sources/aggregated/). To add
  #    one, drop in a single input block: every input not listed in
  #    `infrastructureInputs` is treated as an aggregated downstream repo, so
  #
  #        nix run github:nhooey/skillspkgs#<name>
  #
  #    works for any package any of your repos exposes. Last-write-wins on
  #    name collisions; rename in the source repo to disambiguate.
  # 3. COMBINATIONS — curated unions of skills already provided by (1)/(2),
  #    built inline via `mkAggregateSkillsFlake` (sources/combinations/<name>.nix)
  #    and exposed under their own `combinations.<name>` output, deliberately kept
  #    OUT of `packages.<sys>`.
  #
  # Why the root imports each category's `default.nix` as plain Nix (not `path:` /
  # `?dir=` sub-flake inputs): Garnix's evaluator rejects `path:` flake inputs when
  # this flake is consumed transitively (e.g. from nur-packages). The standalone
  # sub-flakes under `sources/*/flake.nix` and `pkgs/*/flake.nix` remain on disk
  # for direct `github:nhooey/skillspkgs?dir=<path>` consumption.
  inputs = {
    # ---- infrastructure ----
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    systems.url = "github:nix-systems/default";
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # `flake-skills` is the builder library (mkSkillFlake / mkAllSkillsFlake /
    # mkAggregateSkillsFlake / mkSkillsEnv) used to build categories 1 and 3.
    flake-skills = {
      url = "github:nhooey/flake-skills";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ---- CATEGORY 2: first-party repos that ship their own flake (aggregated) ----
    # `flake-skills.follows` keeps these on the same flake-skills rev as
    # skillspkgs itself. Without it, consumers (e.g. nur-packages) see multiple
    # flake-skills nodes in their lock, and the home-manager activation module
    # (loaded from one rev) and the skill derivations (built under another) can
    # drift on their `passthru` contract — e.g. `flakeSkillName missing` at
    # `darwin-rebuild switch` time.
    coding-agent-skills = {
      url = "github:nhooey/coding-agent-skills";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-skills.follows = "flake-skills";
    };
    nix-gstack = {
      url = "github:nhooey/nix-gstack";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    skills-git = {
      url = "github:nhooey/skills-git";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-skills.follows = "flake-skills";
    };
    skills-nix = {
      url = "github:nhooey/skills-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-skills.follows = "flake-skills";
    };

    # ---- CATEGORY 1: vendored third-party sources, no upstream flake (built inline) ----
    # No rev in the URL — `flake.lock` pins these (run `nix flake update <src>`
    # to bump). Embedding a rev would double-pin and make the lock a no-op.
    anthropics-skills-src = {
      url = "github:anthropics/skills";
      flake = false;
    };
    humanizer-src = {
      url = "github:blader/humanizer";
      flake = false;
    };
    superpowers-src = {
      url = "github:obra/superpowers";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-parts,
      flake-skills,
      anthropics-skills-src,
      humanizer-src,
      superpowers-src,
      skills-nix,
      ...
    }@inputs:
    let
      forSystems = nixpkgs.lib.genAttrs (import inputs.systems);

      # Inputs that power this flake itself, not downstream package repos.
      # Everything else in `inputs` is an aggregated category-2 repo. Keep in
      # sync with the input declarations above.
      infrastructureInputs = [
        "self"
        "nixpkgs"
        "flake-parts"
        "systems"
        "devshell"
        "flake-skills"
        "treefmt-nix"
        "anthropics-skills-src"
        "humanizer-src"
        "superpowers-src"
      ];

      # The three source categories, each in its own subdirectory under
      # ./sources/. The root imports each subdir's `default.nix` as plain Nix (no
      # `path:` inputs — see the header comment); each subdir's sibling
      # flake.{nix,lock} is for standalone `?dir=sources/<cat>` consumption only.
      vendored = import ./sources/vendored {
        inherit nixpkgs flake-skills forSystems;
        inherit (inputs) humanizer-src anthropics-skills-src superpowers-src;
      };
      aggregated = import ./sources/aggregated {
        inherit nixpkgs inputs infrastructureInputs;
      };
      combos = import ./sources/combinations {
        inherit
          nixpkgs
          flake-skills
          forSystems
          vendored
          ;
        systems = import inputs.systems;
        inherit (inputs) skills-nix;
      };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [
        inputs.devshell.flakeModule
        inputs.treefmt-nix.flakeModule
      ];

      flake = {
        homeManagerModules.default = import ./lib/home-manager-module.nix;

        templates.default = {
          path = ./templates/skills-repo;
          description = "A first-party Claude Code skills repo using flake-skills.lib.mkAllSkillsFlake";
        };

        # Category 3 — kept OUT of `packages.<sys>`. Each combination exposes
        # `reconcileScript` (declarative devShell installer), `apps`
        # (install/uninstall/preview/reap/reconcile), and a single `env`
        # package (for home-manager). Other repos import these directly.
        inherit (combos) combinations;
      };

      perSystem =
        { system, ... }:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          # Categories 2 (aggregated) + 1 (vendored), per-skill packages only.
          packages = (aggregated.aggregatedFor "packages" system) // vendored.vendoredSkillsFor system;

          legacyPackages = aggregated.aggregatedFor "legacyPackages" system;

          devshells.default = {
            name = "skillspkgs";
            motd = ''
              {bold}{14}🚀 Entering skillspkgs dev shell{reset}
              Run {bold}menu{reset} to list available commands.
            '';
            # Install the authoring combination and the whole skills-git pack
            # at project scope on `nix develop`. Both are declarative +
            # idempotent and own disjoint reconcile appNames
            # (`skillspkgs-authoring` and skills-git's `agent-skills-all`), so
            # they coexist in one scope — each sweeps only its own strays —
            # and re-entry won't clobber the other or other scopes.
            devshell.startup.install-authoring-skills.text = ''
              ${combos.combinations.authoring.${system}.reconcileScript}
            '';
            devshell.startup.install-git-skills.text = ''
              ${inputs.skills-git.apps.${system}.reconcile.program} --scope=project
            '';
            commands = [
              # dev
              {
                category = "dev";
                name = "fmt";
                help = "Format the tree with treefmt";
                command = "nix fmt";
              }
              {
                category = "dev";
                name = "update-flake";
                help = "Update all flake inputs";
                command = "nix flake update";
              }
            ];
            packages = [
              pkgs.jq
              pkgs.python3
            ];
          };

          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt.enable = true;
              shfmt.enable = true;
              yamlfmt.enable = true;
            };
          };
        };
    };
}
