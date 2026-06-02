{
  description = "skillspkgs combinations category — curated cross-cutting unions of skills from categories 1 and 2.";

  # Standalone `?dir=sources/combinations` face. The root flake never reads this
  # — it plain-`import`s ./default.nix, passing the in-memory `vendored.sources`
  # slice directly. This face IS consumed transitively (skills-git pulls it as a
  # single input), so every input must be independently fetchable: the three
  # category-1 skill sources are pulled as their own `github:?dir=pkgs/*` faces,
  # NOT a relative `path:../../pkgs` input — a relative path is dropped from the
  # archived closure under `?dir=`/transitive consumption and fails on isolated
  # builders like Garnix (see skills-nix nix-garnix-ci skill, `[path-inputs]`).
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
    humanizer = {
      url = "github:nhooey/skillspkgs?dir=pkgs/humanizer";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-skills.follows = "flake-skills";
    };
    skill-creator = {
      url = "github:nhooey/skillspkgs?dir=pkgs/skill-creator";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-skills.follows = "flake-skills";
    };
    superpowers = {
      url = "github:nhooey/skillspkgs?dir=pkgs/superpowers";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-skills.follows = "flake-skills";
    };
  };

  outputs =
    {
      nixpkgs,
      systems,
      flake-skills,
      skills-nix,
      humanizer,
      skill-creator,
      superpowers,
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
          ;
        vendoredSources = {
          humanizer = humanizer;
          "skill-creator" = skill-creator;
          superpowers = superpowers;
        };
        systems = import systems;
      };
    in
    {
      inherit (combos) combinations;
    };
}
