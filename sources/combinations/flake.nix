{
  description = "skillspkgs combinations category — curated cross-cutting unions of skills from categories 1 and 2.";

  # Standalone `?dir=sources/combinations` face. The root flake never reads this
  # — it plain-`import`s ./default.nix, passing the in-memory `vendored.sources`
  # slice directly. This face IS consumed transitively (git-skills pulls it as a
  # single input), so every input must be independently fetchable: the four
  # category-1 skill sources are pulled as their own `github:?dir=pkgs/*` faces,
  # NOT a relative `path:../../pkgs` input — a relative path is dropped from the
  # archived closure under `?dir=`/transitive consumption and fails on isolated
  # builders like Garnix (see nix-skills nix-garnix-ci skill, `[path-inputs]`).
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    agent-skill-flake = {
      url = "github:nhooey/agent-skill-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-skills = {
      url = "github:nhooey/nix-skills";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.agent-skill-flake.follows = "agent-skill-flake";
    };
    git-skills = {
      url = "github:nhooey/git-skills";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.agent-skill-flake.follows = "agent-skill-flake";
    };
    daymade = {
      url = "github:nhooey/skillspkgs?dir=pkgs/daymade";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.agent-skill-flake.follows = "agent-skill-flake";
    };
    humanizer = {
      url = "github:nhooey/skillspkgs?dir=pkgs/humanizer";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.agent-skill-flake.follows = "agent-skill-flake";
    };
    skill-creator = {
      url = "github:nhooey/skillspkgs?dir=pkgs/skill-creator";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.agent-skill-flake.follows = "agent-skill-flake";
    };
    superpowers = {
      url = "github:nhooey/skillspkgs?dir=pkgs/superpowers";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.agent-skill-flake.follows = "agent-skill-flake";
    };
  };

  outputs =
    {
      nixpkgs,
      systems,
      agent-skill-flake,
      nix-skills,
      git-skills,
      daymade,
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
          agent-skill-flake
          forSystems
          nix-skills
          git-skills
          ;
        vendoredSources = {
          daymade = daymade;
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
