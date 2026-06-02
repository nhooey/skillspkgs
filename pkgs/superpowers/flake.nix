{
  description = "superpowers — Claude Code skills from obra/superpowers (workflow / review / integration packs).";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-skills = {
      url = "github:nhooey/flake-skills";
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
      flake-skills,
      superpowers-src,
      ...
    }:
    {
      inherit
        (import ./default.nix {
          inherit nixpkgs flake-skills;
          src = superpowers-src;
        })
        packages
        ;
    };
}
