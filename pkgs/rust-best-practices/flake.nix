{
  description = "rust-best-practices — idiomatic Rust practice from Apollo GraphQL's handbook: ownership, errors, Clippy, testing, dispatch (wraps apollographql/skills's skills/rust-best-practices).";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agent-skill-flake = {
      url = "github:nhooey/agent-skill-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    apollographql-skills-src = {
      url = "github:apollographql/skills";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      agent-skill-flake,
      apollographql-skills-src,
      ...
    }:
    {
      inherit
        (import ./default.nix {
          inherit nixpkgs agent-skill-flake;
          src = apollographql-skills-src;
        })
        packages
        ;
    };
}
