{
  description = "skillpkgs — directory of per-skill flake wrappers around third-party Claude Code skills.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
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
      });
}
