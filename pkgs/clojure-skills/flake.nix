{
  description = "clojure-skills — Claude Code skill for structural Clojure editing, nREPL evaluation and clojure-lsp navigation (wraps chaploud/clojure-skills).";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agent-skill-flake = {
      url = "github:nhooey/agent-skill-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    clojure-skills-src = {
      url = "github:chaploud/clojure-skills";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      agent-skill-flake,
      clojure-skills-src,
      ...
    }:
    {
      inherit
        (import ./default.nix {
          inherit nixpkgs agent-skill-flake;
          src = clojure-skills-src;
        })
        packages
        ;
    };
}
