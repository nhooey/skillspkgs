{
  description = "skillspkgs — Claude Code skills aggregator across three categories: (1) vendored third-party skills with no upstream flake, (2) first-party nhooey repos that ship their own flake, and (3) curated cross-cutting skill combinations.";

  # =====================================================================
  # Three categories of skill packages (kept structurally separate below)
  # =====================================================================
  # 1. VENDORED third-party skills — upstream ships no Nix flake, so we
  #    package them here from `flake = false` `*-src` inputs, built inline
  #    (humanizer, skill-creator, superpowers). Per-skill packages land in
  #    `packages.<sys>` under `agent-skill-<name>`.
  # 2. AGGREGATED first-party repos — they ship their own flake; we merge
  #    their `packages` / `legacyPackages` in. To add one, drop in a single
  #    input block: every input not listed in `infrastructureInputs` (in the
  #    `outputs` let-binding) is treated as an aggregated downstream repo, so
  #
  #        nix run github:nhooey/skillspkgs#<name>
  #
  #    works for any package any of your repos exposes. Last-write-wins on
  #    name collisions; rename in the source repo to disambiguate.
  # 3. COMBINATIONS — curated unions of skills already provided by (1)/(2),
  #    built inline via `mkAggregateSkillsFlake` and exposed under their own
  #    `combinations.<name>` output, deliberately kept OUT of `packages.<sys>`.
  #
  # Why everything in (1)/(3) is built inline rather than as `path:` /
  # `?dir=` sub-flake inputs: Garnix's evaluator rejects `path:` flake inputs
  # when this flake is consumed transitively (e.g. from nur-packages). The
  # standalone sub-flakes under `pkgs/*/flake.nix` remain on disk for direct
  # `github:nhooey/skillspkgs?dir=pkgs/<name>` consumption.
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

      # ── Category 2: aggregation machinery ──────────────────────────────
      # Inputs that power this flake itself, not downstream package repos.
      # Everything else in `inputs` is treated as an aggregated repo.
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

      aggregatedInputs = builtins.removeAttrs inputs infrastructureInputs;

      # Strip `default` before merging so one input's `default` doesn't
      # silently shadow another's. Single-package flakes that only expose
      # `default` are promoted to the input's name instead.
      aggregatorMetaKeys = [ "default" ];
      stripAggregatorMeta = attrs: builtins.removeAttrs attrs aggregatorMetaKeys;

      aggregatedFor =
        field: system:
        nixpkgs.lib.foldl' (
          acc: name:
          let
            attrs = aggregatedInputs.${name}.${field}.${system} or { };
            named = stripAggregatorMeta attrs;
            promoted = if attrs ? default && named == { } then { ${name} = attrs.default; } else { };
          in
          acc // promoted // named
        ) { } (builtins.attrNames aggregatedInputs);

      # ── Category 1: vendored third-party skills, built inline ──────────
      # Equivalent to the sub-flakes under `pkgs/*/flake.nix` (kept on disk
      # for standalone `?dir=` consumption) but built directly here so they
      # don't need to be wired as `path:` flake inputs.
      humanizerFor =
        system:
        (flake-skills.lib.mkSkillFlake {
          inherit nixpkgs;
          skillName = "humanizer";
          packageName = "agent-skill-humanizer";
          src = humanizer-src;
        }).packages.${system}.default;

      skillCreatorFor =
        system:
        (flake-skills.lib.mkSkillFlake {
          inherit nixpkgs;
          skillName = "skill-creator";
          packageName = "agent-skill-skill-creator";
          src = "${anthropics-skills-src}/skills/skill-creator";
          # SKILL.md references content under these subdirs; mkSkillFlake
          # ships only SKILL.md / references / scripts by default, so opt
          # them in explicitly.
          extraDirs = [
            "agents"
            "assets"
            "eval-viewer"
          ];
        }).packages.${system}.default;

      # superpowers is multi-skill; mirror `pkgs/superpowers/flake.nix`.
      superpowersBase = flake-skills.lib.mkAllSkillsFlake {
        inherit nixpkgs;
        skillsDir = "${superpowers-src}/skills";
        packagePrefix = "agent-skill-";
      };

      # Named superpowers packs, each a `mkSkillsEnv` (carries
      # passthru.isFlakeSkillsEnv so the home-manager module expands it back
      # into per-skill records on activation).
      superpowersPacks = {
        agent-skills-superpowers-all = [
          "brainstorming"
          "writing-plans"
          "writing-skills"
          "executing-plans"
          "subagent-driven-development"
          "dispatching-parallel-agents"
          "using-superpowers"
          "test-driven-development"
          "systematic-debugging"
          "requesting-code-review"
          "receiving-code-review"
          "verification-before-completion"
          "finishing-a-development-branch"
          "using-git-worktrees"
        ];
        # Workflow & planning — what to do before coding.
        agent-skills-superpowers-workflow = [
          "brainstorming"
          "writing-plans"
          "writing-skills"
          "executing-plans"
          "subagent-driven-development"
          "dispatching-parallel-agents"
          "using-superpowers"
        ];
        # Development & review — how to write and evaluate code.
        agent-skills-superpowers-review = [
          "test-driven-development"
          "systematic-debugging"
          "requesting-code-review"
          "receiving-code-review"
        ];
        # Finishing & integration — verifying, merging, isolating worktrees.
        agent-skills-superpowers-integration = [
          "verification-before-completion"
          "finishing-a-development-branch"
          "using-git-worktrees"
        ];
      };

      # The 14 individual superpowers skills (drops base's `default` /
      # `agent-skills-all` aggregate keys via the `agent-skill-` filter).
      superpowersSkillsFor =
        system:
        nixpkgs.lib.filterAttrs (
          n: _: nixpkgs.lib.hasPrefix "agent-skill-" n
        ) superpowersBase.packages.${system};

      superpowersPacksFor =
        system:
        nixpkgs.lib.mapAttrs (
          packName: skillNames:
          flake-skills.lib.mkSkillsEnv {
            pkgs = nixpkgs.legacyPackages.${system};
            name = packName;
            skills = builtins.map (n: superpowersBase.packages.${system}."agent-skill-${n}") skillNames;
          }
        ) superpowersPacks;

      # Every vendored package exposed in `packages.<sys>`: the two single
      # skills + superpowers' 14 skills + superpowers' named packs.
      vendoredSkillsFor =
        system:
        {
          agent-skill-humanizer = humanizerFor system;
          agent-skill-skill-creator = skillCreatorFor system;
        }
        // superpowersSkillsFor system
        // superpowersPacksFor system;

      # ── Category 3: cross-cutting combinations ─────────────────────────
      # The vendored skills above are bare packages; `mkAggregateSkillsFlake`
      # consumes a source only via `source.packages.<system>`, so wrap each
      # builder as a synthetic source flake. (skills-nix is a real flake
      # input and needs no wrapper.)
      humanizerSource = {
        packages = forSystems (system: {
          agent-skill-humanizer = humanizerFor system;
        });
      };
      skillCreatorSource = {
        packages = forSystems (system: {
          agent-skill-skill-creator = skillCreatorFor system;
        });
      };
      superpowersSource = {
        packages = forSystems (system: superpowersSkillsFor system);
      };

      # The `authoring` combination: skills installed when authoring a skills
      # repo. Mirrors skills-git/skills-authoring/flake.nix exactly (same four
      # sources, same cherry-pick + two prefixes), differing only in that
      # skills-nix is the live aggregated input, the vendored sources are
      # synthetic (no `?dir=`), and the reconcile-ownership `name` is distinct.
      authoringAgg = flake-skills.lib.mkAggregateSkillsFlake {
        inherit nixpkgs;
        systems = import inputs.systems;
        name = "skillspkgs-authoring";
        packagePrefix = "agent-skill-";
        sources = [
          {
            source = skills-nix;
            skills = [
              "nix-flakes"
              "nix-garnix-ci"
            ];
          }
          { source = humanizerSource; }
          {
            source = skillCreatorSource;
            prefix = "anthropic";
          }
          {
            source = superpowersSource;
            prefix = "superpowers";
          }
        ];
      };

      # A single env package per combination, for home-manager consumers
      # (`programs.agent-skills.skills = [ ... ]`). Drawn from the aggregate's
      # already-prefixed package set, since mkSkillsEnv does not re-prefix.
      authoringEnv =
        system:
        flake-skills.lib.mkSkillsEnv {
          pkgs = nixpkgs.legacyPackages.${system};
          name = "agent-skills-authoring";
          skills = builtins.attrValues (
            nixpkgs.lib.filterAttrs (
              n: _: nixpkgs.lib.hasPrefix "agent-skill-" n
            ) authoringAgg.packages.${system}
          );
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
        combinations.authoring = forSystems (system: {
          reconcileScript = authoringAgg.reconcileScript system;
          apps = authoringAgg.apps.${system};
          env = authoringEnv system;
        });
      };

      perSystem =
        { system, ... }:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          # Categories 2 (aggregated) + 1 (vendored), per-skill packages only.
          packages = (aggregatedFor "packages" system) // vendoredSkillsFor system;

          legacyPackages = aggregatedFor "legacyPackages" system;

          devshells.default = {
            name = "skillspkgs";
            motd = ''
              {bold}{14}🚀 Entering skillspkgs dev shell{reset}
              Run {bold}menu{reset} to list available commands.
            '';
            # Install the authoring combination at project scope on
            # `nix develop`. Declarative + idempotent (owns only
            # `skillspkgs-authoring`), so re-entry won't clobber other scopes.
            devshell.startup.install-skills.text = ''
              ${authoringAgg.reconcileScript system}
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
