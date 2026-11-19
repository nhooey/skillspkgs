{
  description = "skillspkgs dev-shell skill set — an isolated sub-flake invoked at RUNTIME by the root devShell, never a root input, so the skill sources live only in THIS flake's lock. It installs the skill-packaging family's combination, as sources/combinations/families.nix defines it.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";

    # The builder lib; it carries no skill inputs.
    agent-skill-flake = {
      url = "github:nhooey/agent-skill-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # This repository's own per-family combinations, through their
    # standalone `?dir=sources/combinations` face. It follows `nixpkgs` but
    # not `agent-skill-flake`, so its sources keep their own compatible
    # builder.
    skillspkgs-combinations = {
      url = "github:nhooey/skillspkgs?dir=sources/combinations";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      agent-skill-flake,
      ...
    }@inputs:
    agent-skill-flake.lib.mkDevshellSkillsFlake {
      inherit nixpkgs;
      systems = import inputs.systems;
      name = "skillspkgs-devshell";
      envName = "agent-skills-skillspkgs-devshell";
      packagePrefix = "agent-skill-";
      sources = [
        { source = inputs.skillspkgs-combinations.combinations.skill-packaging; }
      ];
    };
}
