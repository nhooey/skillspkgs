{
  description = "skillpkgs — directory of per-skill flake wrappers around third-party Claude Code skills, plus aggregator for first-party nhooey skills and tools.";

  # =====================================================================
  # Adding another of your Nix flake repos to this aggregator
  # =====================================================================
  # Add ONE input block below — that's it. Every input that isn't listed
  # in `infrastructureInputs` (in the `outputs` let-binding) is treated
  # as a downstream flake. Its `packages.<system>` and
  # `legacyPackages.<system>` outputs are merged into this flake's, so:
  #
  #     nix run github:nhooey/skillspkgs#<name>
  #
  # works for any package any of your repos exposes.
  #
  # Last-write-wins on name collisions; rename the package in its source
  # repo to disambiguate.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    # Library used to build the inlined third-party skills (humanizer,
    # skill-creator) below. The local sub-flakes under `pkgs/*/flake.nix`
    # remain on disk and stay consumable standalone via
    # `github:nhooey/skillspkgs?dir=pkgs/<name>`, but we no longer
    # reference them as `path:` inputs from this top-level flake —
    # Garnix's evaluator rejects `path:` flake inputs when this flake
    # is consumed transitively (e.g. from nur-packages).
    flake-skills = {
      url = "github:nhooey/flake-skills";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-gstack = {
      url = "github:nhooey/nix-gstack";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # `flake-skills.follows` keeps these sub-flakes on the same flake-skills
    # rev as skillspkgs itself. Without it, consumers (e.g. nur-packages)
    # see multiple flake-skills nodes in their lock, and the home-manager
    # activation module (loaded from one rev) and the skill derivations
    # (built under another) can drift on their `passthru` contract — e.g.
    # `flakeSkillName missing` at `darwin-rebuild switch` time.
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

    coding-agent-skills = {
      url = "github:nhooey/coding-agent-skills";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-skills.follows = "flake-skills";
    };

    # Third-party skill sources, fetched directly so we can build them
    # inline below without going through a `path:` sub-flake.
    humanizer-src = {
      url = "github:blader/humanizer";
      flake = false;
    };

    anthropics-skills-src = {
      url = "github:anthropics/skills";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      flake-skills,
      humanizer-src,
      anthropics-skills-src,
      ...
    }@inputs:
    let
      # Inputs that power this flake itself, not downstream package repos.
      # Everything else in `inputs` is treated as an aggregated repo.
      infrastructureInputs = [
        "self"
        "nixpkgs"
        "flake-utils"
        "flake-skills"
        "humanizer-src"
        "anthropics-skills-src"
      ];

      aggregatedInputs = builtins.removeAttrs inputs infrastructureInputs;

      # Strip `default` before merging so one input's `default` doesn't
      # silently shadow another's. Single-package flakes that only expose
      # `default` are promoted to the input's name instead.
      aggregatorMetaKeys = [ "default" ];
      stripAggregatorMeta = attrs: builtins.removeAttrs attrs aggregatorMetaKeys;

      aggregatedFor =
        field: system:
        nixpkgs.lib.foldl'
          (acc: name:
            let
              attrs = aggregatedInputs.${name}.${field}.${system} or { };
              named = stripAggregatorMeta attrs;
              promoted =
                if attrs ? default && named == { }
                then { ${name} = attrs.default; }
                else { };
            in acc // promoted // named
          )
          { }
          (builtins.attrNames aggregatedInputs);

      # Inlined third-party skills. Equivalent to the sub-flakes under
      # `pkgs/humanizer/` and `pkgs/skill-creator/` (which remain on disk
      # for standalone `?dir=` consumption) but built directly here so
      # they don't need to be wired as `path:` flake inputs.
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
    in
    {
      homeManagerModules.default = import ./lib/home-manager-module.nix;

      templates.default = {
        path = ./templates/skills-repo;
        description = "A first-party Claude Code skills repo using flake-skills.lib.mkAllSkillsFlake";
      };
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [ pkgs.nixpkgs-fmt pkgs.python3 pkgs.jq ];
        };

        packages = (aggregatedFor "packages" system) // {
          agent-skill-humanizer = humanizerFor system;
          agent-skill-skill-creator = skillCreatorFor system;
        };

        legacyPackages = aggregatedFor "legacyPackages" system;
      });
}
