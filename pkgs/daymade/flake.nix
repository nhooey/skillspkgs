{
  description = "daymade — Claude Code skills from daymade/claude-code-skills (skill-creation / claude-code / audio / docs / research / devops / utilities packs).";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-skills = {
      url = "github:nhooey/flake-skills";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    daymade-skills-src = {
      url = "github:daymade/claude-code-skills";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      flake-skills,
      daymade-skills-src,
      ...
    }:
    {
      inherit
        (import ./default.nix {
          inherit nixpkgs flake-skills;
          src = daymade-skills-src;
        })
        packages
        ;
    };
}
