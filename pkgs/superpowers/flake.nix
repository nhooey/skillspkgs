{
  description = "superpowers — Claude Code skills from obra/superpowers (workflow / review / integration packs).";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-skills.url = "github:nhooey/flake-skills";
    flake-skills.inputs.nixpkgs.follows = "nixpkgs";
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
    import ./build.nix {
      inherit nixpkgs flake-skills superpowers-src;
    };
}
