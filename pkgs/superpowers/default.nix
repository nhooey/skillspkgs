# Canonical superpowers module: every skill under obra/superpowers built via
# mkAllSkillsFlake, plus the named pack envs from ./packs.nix, with the
# vendored-category contract. Imported by ./flake.nix (standalone `?dir=` use) and
# by ../default.nix (the root's plain `import` fold).
#
# Unlike humanizer/skill-creator this contributes MANY packages: 14 individual
# `agent-skill-*` skills plus the `agent-skills-superpowers-*` pack envs. The
# generic `default` / `agent-skills-all` aggregates are dropped from both views
# (the latter would collide with a category-2 key).
#
# NOTE — upstream layout caveat.
# `mkAllSkillsFlake` ships only SKILL.md, references/, and scripts/ per skill
# (Anthropic's agent-skill spec). Several obra/superpowers skills carry loose
# top-level companion files outside that whitelist (e.g. systematic-debugging's
# condition-based-waiting.md, writing-skills' anthropic-best-practices.md). The
# core SKILL.md prose still works; to ship the extras, pass `extraFiles` to
# mkAllSkillsFlake and bump the agent-skill-flake rev.
{
  nixpkgs,
  agent-skill-flake,
  src,
}:
let
  inherit (nixpkgs.lib)
    filterAttrs
    hasPrefix
    mapAttrs
    genAttrs
    recursiveUpdate
    ;

  base = agent-skill-flake.lib.mkAllSkillsFlake {
    inherit nixpkgs;
    source = {
      owner = "obra";
    };
    skillsDir = "${src}/skills";
    packagePrefix = "agent-skill-";
  };

  # Pack envs cover exactly the systems mkAllSkillsFlake built for — derive the
  # fanout from `base.packages` rather than restating a platform list, which would
  # drift from the systems the rest of the flake targets (the `nix-systems/default`
  # input).
  forSystems = genAttrs (builtins.attrNames base.packages);

  packs = import ./packs.nix;

  # Pack lists are bare skill names; `base.bySkillName` indexes the per-skill
  # drvs by that stable identity, independent of the owner-namespaced keys.
  mkEnv =
    system: packName: skillNames:
    agent-skill-flake.lib.mkSkillsEnv {
      pkgs = nixpkgs.legacyPackages.${system};
      name = packName;
      skills = builtins.map (n: base.bySkillName.${system}.${n}) skillNames;
    };

  packPackages = forSystems (
    system: mapAttrs (packName: skillNames: mkEnv system packName skillNames) packs
  );

  allPackages = recursiveUpdate base.packages packPackages;

  # Root view: the individual skills plus the named pack envs.
  skillsAndPacks = mapAttrs (
    _: filterAttrs (n: _: hasPrefix "agent-skill-" n || hasPrefix "agent-skills-superpowers-" n)
  ) allPackages;

  # Combinations view: the individual skills only (packs excluded).
  skillsOnly = mapAttrs (_: filterAttrs (n: _: hasPrefix "agent-skill-" n)) allPackages;
in
base
// {
  packages = allPackages;
  vendoredSkills = skillsAndPacks;
  source.packages = skillsOnly;
}
