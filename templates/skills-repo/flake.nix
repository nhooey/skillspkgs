{
  description = "<your-name>: a Claude Code skills repo built with flake-skills.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-skills.url = "github:nhooey/flake-skills";
    flake-skills.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { nixpkgs, flake-skills, ... }:
    flake-skills.lib.mkAllSkillsFlake {
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
