{
  description = "caveman — Claude Code skills from JuliusBrussee/caveman that compress model output into terse \"caveman\" speech to cut token usage while preserving technical accuracy.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agent-skill-flake = {
      url = "github:nhooey/agent-skill-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    caveman-src = {
      url = "github:JuliusBrussee/caveman";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      agent-skill-flake,
      caveman-src,
      ...
    }:
    {
      inherit
        (import ./default.nix {
          inherit nixpkgs agent-skill-flake;
          src = caveman-src;
        })
        packages
        ;
    };
}
