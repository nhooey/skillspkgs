# Canonical skill-creator build. Imported by ./flake.nix (standalone `?dir=`
# consumption) and by the root flake's sources/vendored.nix.
{
  nixpkgs,
  flake-skills,
  src,
}:
flake-skills.lib.mkSkillFlake {
  inherit nixpkgs;
  skillName = "skill-creator";
  packageName = "agent-skill-skill-creator";
  inherit src;
  # SKILL.md references content under these subdirs; mkSkillFlake
  # ships only SKILL.md/references/scripts by default, so opt them
  # in explicitly via extraDirs.
  extraDirs = [
    "agents"
    "assets"
    "eval-viewer"
  ];
}
