{
  description = "typescript-strict — strict TypeScript: unknown at boundaries, no unjustified assertions, one owner per value set, branded types, strict tsconfig (wraps citypaul/.dotfiles's claude/.claude/skills/typescript-strict).";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agent-skill-flake = {
      url = "github:nhooey/agent-skill-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    citypaul-dotfiles-src = {
      url = "github:citypaul/.dotfiles";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      agent-skill-flake,
      citypaul-dotfiles-src,
      ...
    }:
    {
      inherit
        (import ./default.nix {
          inherit nixpkgs agent-skill-flake;
          src = citypaul-dotfiles-src;
        })
        packages
        ;
    };
}
