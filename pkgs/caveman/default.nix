# Canonical caveman module: every skill in JuliusBrussee/caveman built via
# mkAllSkillsFlake, with the vendored-category contract. Imported by ./flake.nix
# (standalone `?dir=pkgs/caveman` use) and by ../default.nix (the root's plain
# `import` fold).
#
# caveman ships its skills in several parallel per-agent trees (`skills/`,
# `plugins/caveman/skills/`, `.agents/`, `.junie/`, `.kiro/`, `.roo/`); the
# top-level `skills/` tree is the canonical Claude Code one and the most
# complete (7 skills: caveman, caveman-commit, caveman-compress, caveman-help,
# caveman-review, caveman-stats, cavecrew). mkAllSkillsFlake's discoverSkills
# recurses, so rooting the call at `${src}/skills` finds exactly those 7 and
# never strays into the other trees. `caveman-compress` carries a `scripts/`
# dir, shipped by the standard whitelist; nothing references a non-standard
# content dir, so no extraDirs/extraFiles are needed.
#
# The upstream owner is `JuliusBrussee`, but a package-key namespace segment
# must be lowercase (^[a-z0-9][a-z0-9-]*$), so `source.owner` is the lowercased
# `juliusbrussee` — package keys are `agent-skill-juliusbrussee-<name>`. The
# installed skill name stays bare.
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
      owner = "juliusbrussee";
    };
    skillsDir = "${src}/skills";
    packagePrefix = "agent-skill-";
  };

  # Root + combinations views: the individual skills only. `hasPrefix
  # "agent-skill-"` keeps the singular per-skill keys and drops both `default`
  # and the plural `agent-skills-juliusbrussee-all` aggregate.
  skillsOnly = mapAttrs (_: filterAttrs (n: _: hasPrefix "agent-skill-" n)) base.packages;
in
base
// {
  vendoredSkills = skillsOnly;
  source.packages = skillsOnly;
}
