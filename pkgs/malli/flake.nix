{
  description = "malli — Claude Code skill for Malli data schemas in Clojure (wraps stoating/clojure-malli-skill).";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agent-skill-flake = {
      url = "github:nhooey/agent-skill-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    clojure-malli-skill-src = {
      url = "github:stoating/clojure-malli-skill";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      agent-skill-flake,
      clojure-malli-skill-src,
      ...
    }:
    {
      inherit
        (import ./default.nix {
          inherit nixpkgs agent-skill-flake;
          src = clojure-malli-skill-src;
        })
        packages
        ;
    };
}
