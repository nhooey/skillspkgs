{
  description = "<your-name>: a Claude Code skills repo built with agent-skill-flake.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agent-skill-flake.url = "github:nhooey/agent-skill-flake";
    agent-skill-flake.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { nixpkgs, agent-skill-flake, ... }:
    agent-skill-flake.lib.mkAllSkillsFlake {
      inherit nixpkgs;
      # Owner namespaces the package keys (agent-skill-<owner>-<name>); the
      # installed skill names stay bare. Set it to your GitHub username, or
      # `namespaceFn = _: "";` to ship un-namespaced keys.
      source = {
        owner = "your-username";
      };
      skillsDir = ./skills;
    };
}
