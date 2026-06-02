{
  description = "skillspkgs combinations category — curated cross-cutting unions of skills from categories 1 and 2.";

  # Standalone `?dir=sources/combinations` face only. The root flake never reads
  # this — it plain-`import`s ./default.nix, passing the in-memory `vendored`
  # value directly. Here `vendored` is pulled via its sibling sub-flake using a
  # relative `path:` input: safe because THIS sub-flake is never consumed
  # transitively (only the ROOT flake is — that's the whole reason the root
  # avoids `path:`), and it locks locally with no chicken-and-egg on the remote.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    flake-skills = {
      url = "github:nhooey/flake-skills";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    skills-nix = {
      url = "github:nhooey/skills-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-skills.follows = "flake-skills";
    };
    vendored = {
      url = "path:../../pkgs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.flake-skills.follows = "flake-skills";
    };
  };

  outputs =
    {
      nixpkgs,
      systems,
      flake-skills,
      skills-nix,
      vendored,
      ...
    }:
    let
      forSystems = nixpkgs.lib.genAttrs (import systems);
      combos = import ./default.nix {
        inherit
          nixpkgs
          flake-skills
          forSystems
          skills-nix
          vendored
          ;
        systems = import systems;
      };
    in
    {
      inherit (combos) combinations;
    };
}
