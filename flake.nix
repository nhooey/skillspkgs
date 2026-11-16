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
    # `agent-skill-flake` is the builder library (mkSkillFlake / mkAllSkillsFlake /
    # mkAggregateSkillsFlake / mkCombination / mkSkillsEnv) used to build
    # categories 1 and 3. It is also the single source of truth for the shared
    # builder infra: flake-parts / systems / devshell / treefmt-nix below alias
    # onto its copies rather than pinning their own, so each collapses to one
    # node in the lock instead of being pinned twice.
    agent-skill-flake = {
      url = "github:nhooey/agent-skill-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.follows = "agent-skill-flake/flake-parts";
    systems.follows = "agent-skill-flake/systems";
    devshell.follows = "agent-skill-flake/devshell";
    treefmt-nix.follows = "agent-skill-flake/treefmt-nix";

    # ---- CATEGORY 2: first-party repos that ship their own flake (aggregated) ----
    # `agent-skill-flake.follows` keeps these on the same agent-skill-flake rev as
    # skillspkgs itself. Without it, consumers (e.g. nur-packages) see multiple
    # agent-skill-flake nodes in their lock, and the home-manager activation module
    # (loaded from one rev) and the skill derivations (built under another) can
    # drift on their `passthru` contract — e.g. `flakeSkillName missing` at
    # `darwin-rebuild switch` time.
    # Each source repo below follows the shared infra inputs (systems /
    # flake-parts / treefmt-nix / devshell) onto this flake's copies — which in
    # turn follow agent-skill-flake's — so the lock keeps one node per infra
    # flake instead of one per source. The aggregated graph is otherwise
    # dominated by duplicate nix-systems / flake-parts / devshell / treefmt-nix
    # subtrees.
    coding-agent-skills = {
      url = "github:nhooey/coding-agent-skills/overnight-skills";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.agent-skill-flake.follows = "agent-skill-flake";
    };
    data-skills = {
      url = "github:nhooey/data-skills/overnight-skills";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.agent-skill-flake.follows = "agent-skill-flake";
    };
    document-skills = {
      url = "github:nhooey/document-skills/overnight-skills";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.agent-skill-flake.follows = "agent-skill-flake";
    };
    git-skills = {
      url = "github:nhooey/git-skills/overnight-skills";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.agent-skill-flake.follows = "agent-skill-flake";
    };
    macos-skills = {
      url = "github:nhooey/macos-skills/overnight-skills";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.agent-skill-flake.follows = "agent-skill-flake";
    };
    nix-gstack = {
      url = "github:nhooey/nix-gstack";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.agent-skill-flake.follows = "agent-skill-flake";
    };
    nix-microsoft-skills = {
      url = "github:nhooey/nix-microsoft-skills/overnight-skills";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.agent-skill-flake.follows = "agent-skill-flake";
    };
    nix-skills = {
      url = "github:nhooey/nix-skills/overnight-skills";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.agent-skill-flake.follows = "agent-skill-flake";
    };
    python-skills = {
      url = "github:nhooey/python-skills/overnight-skills";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.agent-skill-flake.follows = "agent-skill-flake";
    };
    shell-skills = {
      url = "github:nhooey/shell-skills/overnight-skills";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.agent-skill-flake.follows = "agent-skill-flake";
    };
    software-design-skills = {
      url = "github:nhooey/software-design-skills/overnight-skills";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.agent-skill-flake.follows = "agent-skill-flake";
    };
    writing-skills = {
      url = "github:nhooey/writing-skills/overnight-skills";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.agent-skill-flake.follows = "agent-skill-flake";
    };
    xtdb-skills = {
      url = "github:nhooey/xtdb-skills/overnight-skills";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.agent-skill-flake.follows = "agent-skill-flake";
      # xtdb-skills' citation checks come from skill-authoring-skills; its
      # infrastructure follows this flake's too, so the lock keeps one copy.
      inputs.skill-authoring-skills.inputs.systems.follows = "systems";
      inputs.skill-authoring-skills.inputs.flake-parts.follows = "flake-parts";
      inputs.skill-authoring-skills.inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.skill-authoring-skills.inputs.agent-skill-flake.follows = "agent-skill-flake";
    };

    # ---- CATEGORY 1: vendored third-party sources, no upstream flake (built inline) ----
    # No rev in the URL — `flake.lock` pins these (run `nix flake update <src>`
    # to bump). Embedding a rev would double-pin and make the lock a no-op.
    agent-stuff-src = {
      url = "github:mitsuhiko/agent-stuff";
      flake = false;
    };
    anthropics-skills-src = {
      url = "github:anthropics/skills";
      flake = false;
    };
    apollographql-skills-src = {
      url = "github:apollographql/skills";
      flake = false;
    };
    caveman-src = {
      url = "github:JuliusBrussee/caveman";
      flake = false;
    };
    citypaul-dotfiles-src = {
      url = "github:citypaul/.dotfiles";
      flake = false;
    };
    clojure-malli-skill-src = {
      url = "github:stoating/clojure-malli-skill";
      flake = false;
    };
    clojure-shadow-cljs-skill-src = {
      url = "github:stoating/clojure-shadow-cljs-skill";
      flake = false;
    };
    clojure-skills-src = {
      url = "github:chaploud/clojure-skills";
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
    opinionated-claude-skills-src = {
      url = "github:Pyroxin/opinionated-claude-skills";
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
        "agent-stuff-src"
        "anthropics-skills-src"
        "apollographql-skills-src"
        "caveman-src"
        "citypaul-dotfiles-src"
        "clojure-malli-skill-src"
        "clojure-shadow-cljs-skill-src"
        "clojure-skills-src"
        "daymade-skills-src"
        "humanizer-src"
        "opinionated-claude-skills-src"
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
        srcs = import ./pkgs/srcs.nix inputs;
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
        # The category-2 repos the combinations pick skills from.
        skillSources = {
          inherit (inputs)
            coding-agent-skills
            document-skills
            git-skills
            nix-skills
            python-skills
            shell-skills
            software-design-skills
            writing-skills
            ;
        };
      };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      # The devshell-skills module bundles agent-skill-flake's OWN devshell
      # flakeModule, so we do NOT import `inputs.devshell.flakeModule` here too
      # (that would double-import the devshell module). The `devshell` input
      # itself stays declared above (following agent-skill-flake's copy)
      # as an `infrastructureInputs` member.
      imports = [
        inputs.agent-skill-flake.flakeModules.devshellSkills
        inputs.treefmt-nix.flakeModule
        # One `combination-<name>` check per combination: building its env
        # proves every skill it names resolves and no two collide.
        {
          perSystem =
            { system, ... }:
            {
              checks = nixpkgs.lib.mapAttrs' (
                name: combination: nixpkgs.lib.nameValuePair "combination-${name}" combination.env.${system}
              ) combos.combinations;
            };
        }
      ];

      # Dev-shell options consumed by the devshellSkills module above: name the
      # shell, generate the stock motd, reconcile skills-devshell/ at project
      # scope, and prepend the standard ci/dev/maintenance command trio.
      agent-skill-flake.devshellSkills.name = "skillspkgs";

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
          # scripts/skillspkgs as a command; `nix`, `git` and `gh` come from
          # the user's own PATH, as they do for the rest of their work.
          skillspkgs-tool = pkgs.writeShellApplication {
            name = "skillspkgs";
            runtimeInputs = [ pkgs.jq ];
            text = builtins.readFile ./scripts/skillspkgs;
          };
        in
        {
          # Categories 2 (aggregated) + 1 (vendored), per-skill packages only.
          packages = (aggregated.aggregatedFor "packages" system) // vendored.vendoredSkillsFor system;

          legacyPackages = aggregated.aggregatedFor "legacyPackages" system;

          # The motd, the install-skills startup, and the standard + skills
          # command lists all come from agent-skill-flake.flakeModules.
          # devshellSkills (imported above). We only set the name and add this
          # repo's own packages; the module's command lists merge with ours.
          devshells.default.packages = [
            pkgs.jq
            pkgs.python3
          ];
          devshells.default.commands = [
            {
              category = "maintenance";
              package = skillspkgs-tool;
              help = "Bump skill inputs and keep the sources/aggregated lock in step (skillspkgs --help)";
            }
          ];

          # `sources/aggregated/flake.{nix,lock}` is a second copy of the
          # category-2 inputs (see its header), and bumping the root's lock
          # leaves its lock behind. A stale rev there can stop evaluating under
          # the agent-skill-flake it pins while the root still works. Fail if it
          # declares a different repo set or locks any of them (or
          # agent-skill-flake) at a different rev than the root; its own
          # `nix flake check` then evaluates it as a skills source.
          checks.aggregated-subflake-in-sync =
            let
              inherit (nixpkgs) lib;
              rootLock = lib.importJSON ./flake.lock;
              subLock = lib.importJSON ./sources/aggregated/flake.lock;
              # A `follows` input is a path list, not a node name; it pins nothing.
              revOf =
                lock: name:
                let
                  node = lock.nodes.root.inputs.${name} or null;
                in
                if builtins.isString node then lock.nodes.${node}.locked.rev else null;
              rootRepos = builtins.attrNames (builtins.removeAttrs inputs infrastructureInputs);
              subRepos = builtins.attrNames (
                builtins.removeAttrs subLock.nodes.root.inputs [
                  "nixpkgs"
                  "systems"
                  "agent-skill-flake"
                ]
              );
              missing = lib.subtractLists subRepos rootRepos;
              extra = lib.subtractLists rootRepos subRepos;
              drifted = builtins.filter (n: revOf rootLock n != revOf subLock n) (
                [ "agent-skill-flake" ] ++ lib.intersectLists rootRepos subRepos
              );
              problems =
                map (n: "missing from sources/aggregated: ${n}") missing
                ++ map (n: "not aggregated by the root: ${n}") extra
                ++ map (
                  n:
                  "${n}: root locks ${toString (revOf rootLock n)}, sources/aggregated locks ${toString (revOf subLock n)}"
                ) drifted;
            in
            pkgs.runCommand "aggregated-subflake-in-sync" { } (
              if problems == [ ] then
                "touch $out"
              else
                ''
                  cat >&2 <<'EOF'
                  sources/aggregated/flake.{nix,lock} has drifted from the root flake:
                    ${lib.concatStringsSep "\n  " problems}
                  Declare the same repos in both, then pin the sub-flake to the root's revs
                  by running `skillspkgs sync-aggregated` in the dev shell.
                  EOF
                  exit 1
                ''
            );

          # The same check `nix flake check ./sources/aggregated` runs, over the
          # root's copy of the aggregated repos, which the check above holds at
          # the sub-flake's revs: consume them as a dev-shell skills source and
          # build the reconcile app over every skill they expose.
          checks.aggregated-as-skills-source =
            let
              devshell = agent-skill-flake.lib.mkDevshellSkillsFlake {
                inherit nixpkgs;
                systems = [ system ];
                name = "aggregated-check";
                sources = [
                  {
                    source = {
                      packages.${system} = aggregated.aggregatedFor "packages" system;
                      legacyPackages.${system} = aggregated.aggregatedFor "legacyPackages" system;
                    };
                  }
                ];
              };
            in
            pkgs.writeText "aggregated-as-skills-source" (
              builtins.toJSON {
                packages = builtins.attrNames devshell.packages.${system};
                reconcile = devshell.apps.${system}.reconcile.program;
              }
            );

          checks.home-manager-module = import ./tests/home-manager-module.nix { inherit pkgs; };

          # Lint scripts/skillspkgs and unit-test its pure functions.
          checks.skillspkgs-tool =
            pkgs.runCommand "skillspkgs-tool-test"
              {
                src = nixpkgs.lib.fileset.toSource {
                  root = ./.;
                  fileset = nixpkgs.lib.fileset.unions [
                    ./scripts/skillspkgs
                    ./tests/skillspkgs.bats
                  ];
                };
                nativeBuildInputs = [
                  pkgs.bats
                  pkgs.jq
                  pkgs.shellcheck
                ];
              }
              ''
                cd $src
                shellcheck --external-sources scripts/skillspkgs tests/skillspkgs.bats
                bats tests/skillspkgs.bats
                touch $out
              '';

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
