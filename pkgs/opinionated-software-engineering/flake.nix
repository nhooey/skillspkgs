{
  description = "opinionated-software-engineering — the six SICP-grounded software-engineering skills (software-engineer, TDD, functional/OOP/logic programming, git) from the opinionated-software-engineering plugin of Pyroxin/opinionated-claude-skills.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agent-skill-flake = {
      url = "github:nhooey/agent-skill-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    opinionated-claude-skills-src = {
      url = "github:Pyroxin/opinionated-claude-skills";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      agent-skill-flake,
      opinionated-claude-skills-src,
      ...
    }:
    {
      inherit
        (import ./default.nix {
          inherit nixpkgs agent-skill-flake;
          src = opinionated-claude-skills-src;
        })
        packages
        ;
    };
}
