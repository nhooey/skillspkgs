# Shared builder for single-skill vendored modules whose only variation is the
# skill name, package key, and an optional source subpath. humanizer and
# skill-creator both reduce to this; superpowers stays bespoke in its own
# default.nix (it builds many skills plus pack envs).
#
# Returns the same contract as a hand-written pkgs/<name>/default.nix:
#   built // { vendoredSkills; source.packages; }
# where `built` is the mkSkillFlake output (full packages, incl. the `default`
# alias) for the standalone face, and the two added views drop everything but the
# `agent-skill-*` keys for the root package set and the combinations category.
{
  nixpkgs,
  flake-skills,
  src,
  skillName,
  packageName,
  # Optional path under `src` to the skill. Upstreams that ship many skills in
  # one repo (e.g. anthropics/skills) need this; null uses `src` as-is.
  srcSubpath ? null,
}:
let
  inherit (nixpkgs.lib) filterAttrs hasPrefix mapAttrs;

  built = flake-skills.lib.mkSkillFlake {
    inherit nixpkgs skillName packageName;
    src = if srcSubpath == null then src else "${src}/${srcSubpath}";
  };

  skillsOnly = mapAttrs (_: filterAttrs (n: _: hasPrefix "agent-skill-" n)) built.packages;
in
built
// {
  vendoredSkills = skillsOnly;
  source.packages = skillsOnly;
}
