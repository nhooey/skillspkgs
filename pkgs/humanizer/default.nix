# Canonical humanizer module: builds blader/humanizer into an installable skill
# and exposes the vendored-category contract. Imported by ./flake.nix (standalone
# `?dir=pkgs/humanizer` consumption) and by ../default.nix (the vendored-category
# fold the root flake reads via plain `import` — no `path:` input). Single source
# of truth for this skill; the build invocation lives in exactly one place.
{
  nixpkgs,
  flake-skills,
  src,
}:
let
  inherit (nixpkgs.lib) filterAttrs hasPrefix mapAttrs;

  built = flake-skills.lib.mkSkillFlake {
    inherit nixpkgs src;
    skillName = "humanizer";
    packageName = "agent-skill-humanizer";
  };

  # Per system, drop the `default` alias — keep only the `agent-skill-*` key that
  # surfaces in the root package set and feeds the combinations category.
  skillsOnly = mapAttrs (_: filterAttrs (n: _: hasPrefix "agent-skill-" n)) built.packages;
in
built
// {
  # The root's `packages.<sys>` view (folded by ../default.nix).
  vendoredSkills = skillsOnly;
  # The combinations-category source view (`mkAggregateSkillsFlake` reads
  # `source.packages.<system>`).
  source.packages = skillsOnly;
}
