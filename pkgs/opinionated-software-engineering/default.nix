# Canonical opinionated-software-engineering module: the six skills under the
# `opinionated-software-engineering` plugin of Pyroxin/opinionated-claude-skills,
# built via mkAllSkillsFlake with the vendored-category contract. Imported by
# ./flake.nix (standalone `?dir=pkgs/opinionated-software-engineering` use) and by
# ../default.nix (the root's plain `import` fold).
#
# Pyroxin/opinionated-claude-skills is a monorepo of several independent skill
# plugins (opinionated-apple-development, opinionated-python-development, ...);
# this wrapper vendors only the `opinionated-software-engineering` one, so the
# `src` is the whole repo and the build is rooted at that plugin's `skills/`
# subdir. mkAllSkillsFlake's discoverSkills treats any dir holding a SKILL.md as a
# leaf, so the call finds exactly the six skills there (software-engineer,
# test-driven-development, functional-programmer, object-oriented-programmer,
# logic-programmer, git-version-control). Each skill is a lone SKILL.md with no
# references/ or scripts/, so no extraDirs/extraFiles are needed.
#
# The upstream owner is `Pyroxin`, but a package-key namespace segment must be
# lowercase (^[a-z0-9][a-z0-9-]*$), so `source.owner` is the lowercased `pyroxin`
# — package keys are `agent-skill-pyroxin-<name>`. The installed skill name stays
# bare.
{
  nixpkgs,
  agent-skill-flake,
  src,
}:
let
  inherit (nixpkgs.lib) filterAttrs hasPrefix mapAttrs;

  base = agent-skill-flake.lib.mkAllSkillsFlake {
    inherit nixpkgs;
    source = {
      owner = "pyroxin";
    };
    skillsDir = "${src}/opinionated-software-engineering/skills";
    packagePrefix = "agent-skill-";
  };

  # Root + combinations views: the individual skills only. `hasPrefix
  # "agent-skill-"` keeps the singular per-skill keys and drops both `default`
  # and the plural `agent-skills-pyroxin-all` aggregate.
  skillsOnly = mapAttrs (_: filterAttrs (n: _: hasPrefix "agent-skill-" n)) base.packages;
in
base
// {
  vendoredSkills = skillsOnly;
  source.packages = skillsOnly;
}
