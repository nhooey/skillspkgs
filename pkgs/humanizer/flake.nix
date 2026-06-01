{
  description = "humanizer — Claude Code skill that removes signs of AI-generated writing (wraps blader/humanizer).";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-skills.url = "github:nhooey/flake-skills";
    flake-skills.inputs.nixpkgs.follows = "nixpkgs";
    humanizer-src = {
      url = "github:blader/humanizer";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      flake-skills,
      humanizer-src,
      ...
    }:
    flake-skills.lib.mkSkillFlake {
      inherit nixpkgs;
      skillName = "humanizer";
      packageName = "agent-skill-humanizer";
      src = humanizer-src;
    };
}
