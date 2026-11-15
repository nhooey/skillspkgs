{
  description = "skillspkgs combinations category — curated cross-cutting unions of skills from categories 1 and 2.";

  # Standalone `?dir=sources/combinations` face. The root flake never reads this
  # — it plain-`import`s ./default.nix, passing the in-memory `vendored.sources`
  # slice directly. This face IS consumed transitively (git-skills pulls it as a
  # single input), so every input must be independently fetchable: the three
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
    coding-agent-skills = {
      url = "github:nhooey/coding-agent-skills/overnight-skills";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.agent-skill-flake.follows = "agent-skill-flake";
    };
    document-skills = {
      url = "github:nhooey/document-skills/overnight-skills";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.agent-skill-flake.follows = "agent-skill-flake";
    };
    git-skills = {
      url = "github:nhooey/git-skills/overnight-skills";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.agent-skill-flake.follows = "agent-skill-flake";
    };
    nix-skills = {
      url = "github:nhooey/nix-skills/overnight-skills";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.agent-skill-flake.follows = "agent-skill-flake";
    };
    python-skills = {
      url = "github:nhooey/python-skills/overnight-skills";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.agent-skill-flake.follows = "agent-skill-flake";
    };
    shell-skills = {
      url = "github:nhooey/shell-skills/overnight-skills";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.agent-skill-flake.follows = "agent-skill-flake";
    };
    software-design-skills = {
      url = "github:nhooey/software-design-skills/overnight-skills";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.agent-skill-flake.follows = "agent-skill-flake";
    };
    writing-skills = {
      url = "github:nhooey/writing-skills/overnight-skills";
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
      humanizer,
      skill-creator,
      superpowers,
      ...
    }@inputs:
    let
      forSystems = nixpkgs.lib.genAttrs (import systems);
      combos = import ./default.nix {
        inherit
          nixpkgs
          agent-skill-flake
          forSystems
          ;
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
