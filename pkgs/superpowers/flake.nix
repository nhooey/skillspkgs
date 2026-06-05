{
  description = "superpowers — Claude Code skills from obra/superpowers (workflow / review / integration packs).";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agent-skill-flake = {
      url = "github:nhooey/agent-skill-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    superpowers-src = {
      url = "github:obra/superpowers";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      agent-skill-flake,
      superpowers-src,
      ...
    }:
    {
      inherit
        (import ./default.nix {
          inherit nixpkgs agent-skill-flake;
          src = superpowers-src;
        })
        packages
        ;
    };
}
