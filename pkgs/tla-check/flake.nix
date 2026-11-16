{
  description = "tla-check — write TLA+ specs and TLC configs from a design, run TLC and report counterexamples with their bounds and assumptions (wraps younes-io/agent-skills's plugins/tla-workbenches/skills/tla-check).";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agent-skill-flake = {
      url = "github:nhooey/agent-skill-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    younes-io-agent-skills-src = {
      url = "github:younes-io/agent-skills";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      agent-skill-flake,
      younes-io-agent-skills-src,
      ...
    }:
    {
      inherit
        (import ./default.nix {
          inherit nixpkgs agent-skill-flake;
          src = younes-io-agent-skills-src;
        })
        packages
        ;
    };
}
