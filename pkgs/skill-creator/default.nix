# Canonical skill-creator module: builds Anthropic's official skill-creator (the
# `skills/skill-creator` subdir of anthropics/skills) into an installable skill
# and exposes the vendored-category contract. Imported by ./flake.nix (standalone
# `?dir=pkgs/skill-creator` consumption) and by ../default.nix (the root's plain
# `import` fold). The subpath slice lives here, so both faces pass the raw
# anthropics-skills-src and the slicing is written exactly once.
{
  nixpkgs,
  flake-skills,
  src,
}:
let
  inherit (nixpkgs.lib) filterAttrs hasPrefix mapAttrs;

  built = flake-skills.lib.mkSkillFlake {
    inherit nixpkgs;
    src = "${src}/skills/skill-creator";
    skillName = "skill-creator";
    packageName = "agent-skill-skill-creator";
  };

  skillsOnly = mapAttrs (_: filterAttrs (n: _: hasPrefix "agent-skill-" n)) built.packages;
in
built
// {
  vendoredSkills = skillsOnly;
  source.packages = skillsOnly;
}
