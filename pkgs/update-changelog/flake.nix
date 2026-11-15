{
  description = "update-changelog — writes a changelog's Unreleased section from the commits since the last tag (wraps mitsuhiko/agent-stuff's skills/update-changelog).";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agent-skill-flake = {
      url = "github:nhooey/agent-skill-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agent-stuff-src = {
      url = "github:mitsuhiko/agent-stuff";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      agent-skill-flake,
      agent-stuff-src,
      ...
    }:
    {
      inherit
        (import ./default.nix {
          inherit nixpkgs agent-skill-flake;
          src = agent-stuff-src;
        })
        packages
        ;
    };
}
