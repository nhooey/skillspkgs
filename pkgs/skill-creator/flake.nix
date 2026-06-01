{
  description = "skill-creator — Anthropic's official skill for authoring, evaluating, and iterating on Claude Code skills (wraps anthropics/skills' skill-creator subdir).";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-skills.url = "github:nhooey/flake-skills";
    flake-skills.inputs.nixpkgs.follows = "nixpkgs";
    anthropics-skills-src = {
      url = "github:anthropics/skills";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      flake-skills,
      anthropics-skills-src,
      ...
    }:
    flake-skills.lib.mkSkillFlake {
      inherit nixpkgs;
      skillName = "skill-creator";
      packageName = "agent-skill-skill-creator";
      src = "${anthropics-skills-src}/skills/skill-creator";
      # SKILL.md references content under these subdirs; mkSkillFlake
      # ships only SKILL.md/references/scripts by default, so opt them
      # in explicitly via extraDirs.
      extraDirs = [
        "agents"
        "assets"
        "eval-viewer"
      ];
    };
}
