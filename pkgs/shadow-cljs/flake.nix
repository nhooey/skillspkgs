{
  description = "shadow-cljs — Claude Code skill for the shadow-cljs ClojureScript build tool (wraps stoating/clojure-shadow-cljs-skill).";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agent-skill-flake = {
      url = "github:nhooey/agent-skill-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    clojure-shadow-cljs-skill-src = {
      url = "github:stoating/clojure-shadow-cljs-skill";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      agent-skill-flake,
      clojure-shadow-cljs-skill-src,
      ...
    }:
    {
      inherit
        (import ./default.nix {
          inherit nixpkgs agent-skill-flake;
          src = clojure-shadow-cljs-skill-src;
        })
        packages
        ;
    };
}
