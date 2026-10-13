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
# NOTE — upstream layout caveat, settled by the `extraFiles` below.
# `mkAllSkillsFlake` ships only SKILL.md, references/, and scripts/ per skill
# (Anthropic's agent-skill spec). Eight of the fourteen obra/superpowers skills
# carry 26 loose top-level companion files outside that whitelist, and their
# SKILL.md files name them: subagent-driven-development's three dispatch prompts,
# requesting-code-review's code-reviewer.md, writing-skills'
# anthropic-best-practices.md and render-graphs.js, systematic-debugging's ten.
# Without them a skill sends its reader to a file the install does not hold, so
# the `extraFiles` globs below ship every loose file the collection carries —
# the set mk-all-skills-flake.nix documents for exactly this source. The pinned
# agent-skill-flake rev already takes the argument, so no bump goes with it.
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
    extraFiles = [
      "*.md"
      "*.sh"
      "*.ts"
      "*.js"
      "*.dot"
    ];
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
