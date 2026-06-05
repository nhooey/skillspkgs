{
  description = "skillspkgs — Claude Code skills aggregator across three categories: (1) vendored third-party skills with no upstream flake, (2) first-party nhooey repos that ship their own flake, and (3) curated cross-cutting skill combinations.";

  # =====================================================================
  # Three categories of skill packages
  # =====================================================================
  # `pkgs/` holds the things we build (category 1); `sources/` holds how we
  # aggregate and combine (categories 2 and 3). The root `import`s each category's
  # `default.nix` as plain Nix; a sibling flake.{nix,lock} provides a standalone
  # `?dir=` face. The vendored/combinations folds auto-discover their members, so
  # adding a skill is mostly a matter of dropping in a new file or directory.
  # 1. VENDORED third-party skills — upstream ships no Nix flake, so we package
  #    them here from `flake = false` `*-src` inputs. Each skill is self-contained
  #    under pkgs/<name>/: a canonical `default.nix` (build + category contract),
  #    a thin `flake.nix` standalone `?dir=pkgs/<name>` face, and (superpowers)
  #    `packs.nix`. pkgs/default.nix auto-discovers and folds them; the root passes
  #    each skill's locked source via the `srcs` map below. Per-skill packages land
  #    in `packages.<sys>` under `agent-skill-<name>`.
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
  #    built via `mkCombination` (sources/combinations/<name>.nix) and exposed
  #    under their own `combinations.<name>` output, deliberately kept OUT of
  #    `packages.<sys>`.
  #
  # Why the root imports each category's `default.nix` as plain Nix (not `path:` /
  # `?dir=` sub-flake inputs): Garnix's evaluator rejects `path:` flake inputs when
  # this flake is consumed transitively (e.g. from nur-packages). The standalone
  # sub-flakes under `pkgs/flake.nix`, `pkgs/*/flake.nix`, and `sources/*/flake.nix`
  # remain on disk for direct `github:nhooey/skillspkgs?dir=<path>` consumption.
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
    # `agent-skill-flake` is the builder library (mkSkillFlake / mkAllSkillsFlake /
    # mkAggregateSkillsFlake / mkCombination / mkSkillsEnv) used to build
    # categories 1 and 3.
    agent-skill-flake = {
      url = "github:nhooey/agent-skill-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ---- CATEGORY 2: first-party repos that ship their own flake (aggregated) ----
    # `agent-skill-flake.follows` keeps these on the same agent-skill-flake rev as
    # skillspkgs itself. Without it, consumers (e.g. nur-packages) see multiple
    # agent-skill-flake nodes in their lock, and the home-manager activation module
    # (loaded from one rev) and the skill derivations (built under another) can
    # drift on their `passthru` contract — e.g. `flakeSkillName missing` at
    # `darwin-rebuild switch` time.
    # Each source repo below follows the shared infra inputs (systems /
    # flake-parts / treefmt-nix / devshell) onto this flake's copies, so the
    # lock keeps one node per infra flake instead of one per source — the
    # aggregated graph is otherwise dominated by duplicate nix-systems /
    # flake-parts / devshell / treefmt-nix subtrees.
    coding-agent-skills = {
      url = "github:nhooey/coding-agent-skills";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.devshell.follows = "devshell";
      inputs.agent-skill-flake.follows = "agent-skill-flake";
    };
    git-skills = {
      url = "github:nhooey/git-skills";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.devshell.follows = "devshell";
      inputs.agent-skill-flake.follows = "agent-skill-flake";
    };
    nix-gstack = {
      url = "github:nhooey/nix-gstack";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.devshell.follows = "devshell";
      inputs.agent-skill-flake.follows = "agent-skill-flake";
    };
    nix-microsoft-skills = {
      url = "github:nhooey/nix-microsoft-skills";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.devshell.follows = "devshell";
      inputs.agent-skill-flake.follows = "agent-skill-flake";
    };
    nix-skills = {
      url = "github:nhooey/nix-skills";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.devshell.follows = "devshell";
      inputs.agent-skill-flake.follows = "agent-skill-flake";
    };

    # ---- CATEGORY 1: vendored third-party sources, no upstream flake (built inline) ----
    # No rev in the URL — `flake.lock` pins these (run `nix flake update <src>`
    # to bump). Embedding a rev would double-pin and make the lock a no-op.
    anthropics-skills-src = {
      url = "github:anthropics/skills";
      flake = false;
    };
    daymade-skills-src = {
      url = "github:daymade/claude-code-skills";
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
    trailofbits-skills-src = {
      url = "github:trailofbits/skills";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-parts,
      agent-skill-flake,
      anthropics-skills-src,
      humanizer-src,
      superpowers-src,
      nix-skills,
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
        "agent-skill-flake"
        "treefmt-nix"
        "anthropics-skills-src"
        "daymade-skills-src"
        "humanizer-src"
        "superpowers-src"
        "trailofbits-skills-src"
      ];

      # The three source categories, each in its own subdirectory under
      # ./sources/. The root imports each subdir's `default.nix` as plain Nix (no
      # `path:` inputs — see the header comment); each subdir's sibling
      # flake.{nix,lock} is for standalone `?dir=sources/<cat>` consumption only.
      vendored = import ./pkgs {
        inherit nixpkgs agent-skill-flake;
        # Locked sources keyed by pkgs/<name> dir; each module slices its own
        # subpath (e.g. skill-creator reads `skills/skill-creator`).
        srcs = {
          daymade = inputs.daymade-skills-src;
          humanizer = inputs.humanizer-src;
          "skill-creator" = inputs.anthropics-skills-src;
          superpowers = inputs.superpowers-src;
          trailofbits = inputs.trailofbits-skills-src;
        };
      };
      aggregated = import ./sources/aggregated {
        inherit nixpkgs inputs infrastructureInputs;
      };
      combos = import ./sources/combinations {
        inherit
          nixpkgs
          agent-skill-flake
          forSystems
          ;
        vendoredSources = vendored.sources;
        systems = import inputs.systems;
        inherit (inputs) nix-skills git-skills;
      };

      # Root-side wiring for the `skills-devshell/` sub-flake: the dev-shell
      # skill set (skillspkgs' own `authoring-with-git` combination) is defined
      # in that isolated sub-flake and invoked here at RUNTIME, never as a root
      # input. skillspkgs still aggregates its skill sources for the package
      # outputs; only the dev-shell install moved off the root.
      devshellSkills = agent-skill-flake.lib.devshellSkillsHook { };
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
          description = "A first-party Claude Code skills repo using agent-skill-flake.lib.mkAllSkillsFlake";
        };

        # Category 3 — kept OUT of `packages.<sys>`. Each combination is a
        # system-parametric mkCombination result: `reconcileScript system`
        # (declarative devShell installer), `apps.<sys>`, `env.<sys>` (a single
        # home-manager package), and `packages.<sys>` (so the whole combination
        # is itself a valid `{ source = …; }`). Other repos import these directly.
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
            # Reconcile the dev-shell skill set (skillspkgs' own
            # authoring-with-git combination) at project scope on `nix develop`,
            # by invoking the `skills-devshell/` sub-flake at RUNTIME via the
            # hook — declarative + idempotent, and never a root input.
            devshell.startup.install-skills.text = devshellSkills.startup;
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
            ]
            ++ devshellSkills.commands;
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
