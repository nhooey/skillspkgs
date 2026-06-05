{
  description = "humanizer — Claude Code skill that removes signs of AI-generated writing (wraps blader/humanizer).";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agent-skill-flake = {
      url = "github:nhooey/agent-skill-flake";
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
      agent-skill-flake,
      humanizer-src,
      ...
    }:
    {
      inherit
        (import ./default.nix {
          inherit nixpkgs agent-skill-flake;
          src = humanizer-src;
        })
        packages
        ;
    };
}
