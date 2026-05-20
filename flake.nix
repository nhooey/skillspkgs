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

    nix-gstack = {
      url = "github:nhooey/nix-gstack";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    skills-git = {
      url = "github:nhooey/skills-git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    skills-nix = {
      url = "github:nhooey/skills-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    humanizer = {
      url = "path:./pkgs/humanizer";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    skill-creator = {
      url = "path:./pkgs/skill-creator";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    let
      # Inputs that power this flake itself, not downstream package repos.
      # Everything else in `inputs` is treated as an aggregated repo.
      infrastructureInputs = [ "self" "nixpkgs" "flake-utils" ];

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

        packages = aggregatedFor "packages" system;
        legacyPackages = aggregatedFor "legacyPackages" system;
      });
}
