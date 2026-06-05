{
  description = "skill-creator — Anthropic's official skill for authoring, evaluating, and iterating on Claude Code skills (wraps anthropics/skills' skill-creator subdir).";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agent-skill-flake = {
      url = "github:nhooey/agent-skill-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    anthropics-skills-src = {
      url = "github:anthropics/skills";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      agent-skill-flake,
      anthropics-skills-src,
      ...
    }:
    {
      inherit
        (import ./default.nix {
          inherit nixpkgs agent-skill-flake;
          src = anthropics-skills-src;
        })
        packages
        ;
    };
}
