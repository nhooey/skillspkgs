{
  description = "pstack formal verification — create-formal-verification-skill picks the code where a bug costs most and leaves a verify skill for it; maintain-formal-verification-skill keeps that verification in step with the code (wraps cursor/plugins's pstack/skills, patched).";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agent-skill-flake = {
      url = "github:nhooey/agent-skill-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cursor-plugins-src = {
      url = "github:cursor/plugins";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      agent-skill-flake,
      cursor-plugins-src,
      ...
    }:
    {
      inherit
        (import ./default.nix {
          inherit nixpkgs agent-skill-flake;
          src = cursor-plugins-src;
        })
        packages
        ;
    };
}
