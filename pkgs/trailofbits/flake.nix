{
  description = "trailofbits — Claude Code security-audit skills from trailofbits/skills (vulnerability scanners, fuzzing/testing-handbook guidance, static analysis, cryptography review).";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agent-skill-flake = {
      url = "github:nhooey/agent-skill-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    trailofbits-skills-src = {
      url = "github:trailofbits/skills";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      agent-skill-flake,
      trailofbits-skills-src,
      ...
    }:
    {
      inherit
        (import ./default.nix {
          inherit nixpkgs agent-skill-flake;
          src = trailofbits-skills-src;
        })
        packages
        ;
    };
}
