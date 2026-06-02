{
  description = "humanizer — Claude Code skill that removes signs of AI-generated writing (wraps blader/humanizer).";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-skills = {
      url = "github:nhooey/flake-skills";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    humanizer-src = {
      url = "github:blader/humanizer";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      flake-skills,
      humanizer-src,
      ...
    }:
    {
      inherit
        (import ./default.nix {
          inherit nixpkgs flake-skills;
          src = humanizer-src;
        })
        packages
        ;
    };
}
