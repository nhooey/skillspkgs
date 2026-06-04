# Canonical daymade module: every skill under daymade/claude-code-skills built
# via mkAllSkillsFlake, plus the disjoint topical packs from ./packs.nix, with
# the vendored-category contract. Imported by ./flake.nix (standalone `?dir=`
# use) and by ../default.nix (the root's plain `import` fold).
#
# Like superpowers (and unlike humanizer/skill-creator) this contributes MANY
# packages: 58 individual `agent-skill-daymade-*` skills plus the
# `agent-skills-daymade-*` pack envs. The seven topical packs are a disjoint
# partition of all 58; `agent-skills-daymade-all` is the single overlapping
# bundle.
#
# Two upstream-layout facts shape the build:
#   • Skills live at the REPO ROOT (38 standalone), not under a `skills/` dir,
#     alongside non-skill dirs (demos/, references/, scripts/). discoverSkills
#     keys on a top-level SKILL.md, so those are skipped automatically.
#   • Four "suite" dirs (daymade-audio, daymade-claude-code, daymade-docs,
#     daymade-skill) carry no SKILL.md themselves — their skills sit one level
#     down. So each suite is its own mkAllSkillsFlake `skillsDir`, and the five
#     groups (root + 4 suites) are merged here.
#
# Every skill is renamed `daymade-<name>` (lowercased — daymade ships one
# uppercase dir, iOS-APP-developer, which would fail Claude Code's
# ^[a-z0-9-]{1,64}$ name rule otherwise). The prefix also keeps daymade's
# skill-creator from colliding with anthropics/skills' skill-creator in the
# root package set.
{
  nixpkgs,
  flake-skills,
  src,
}:
let
  inherit (nixpkgs.lib)
    filterAttrs
    foldl'
    genAttrs
    hasPrefix
    mapAttrs
    removeAttrs
    toLower
    ;

  renameFn = ctx: "daymade-" + toLower ctx.name;

  # One mkAllSkillsFlake call per skillsDir: the repo root (38 standalone) plus
  # each suite (its nested skills). "." means the repo root itself.
  groupDirs = [
    "."
    "daymade-audio"
    "daymade-claude-code"
    "daymade-docs"
    "daymade-skill"
  ];

  buildGroup =
    dir:
    flake-skills.lib.mkAllSkillsFlake {
      inherit nixpkgs renameFn;
      skillsDir = if dir == "." then "${src}" else "${src}/${dir}";
      packagePrefix = "agent-skill-";
    };

  groups = map buildGroup groupDirs;

  # Systems the whole flake targets, taken from the groups themselves rather than
  # restating a platform list (mkAllSkillsFlake fans out over nix-systems/default).
  forSystems = genAttrs (builtins.attrNames (builtins.head groups).packages);

  # Each group's `packages.<sys>` carries its own generic `default` /
  # `agent-skills-all` aggregate (covering only that group); drop both before
  # merging so the union is exactly the `agent-skill-daymade-*` per-skill keys.
  dropAggregates =
    pkgs:
    removeAttrs pkgs [
      "default"
      "agent-skills-all"
    ];

  mergedSkillsFor = system: foldl' (acc: g: acc // dropAggregates g.packages.${system}) { } groups;

  packs = import ./packs.nix;

  # Pack lists hold pre-rename directory names; map each to its renamed,
  # lowercased package key. iOS-APP-developer -> agent-skill-daymade-ios-app-developer.
  mkEnv =
    system: packName: skillNames:
    flake-skills.lib.mkSkillsEnv {
      pkgs = nixpkgs.legacyPackages.${system};
      name = packName;
      skills = map (n: (mergedSkillsFor system)."agent-skill-daymade-${toLower n}") skillNames;
    };

  packPackagesFor = system: mapAttrs (packName: skillNames: mkEnv system packName skillNames) packs;

  packages = forSystems (
    system:
    let
      packsP = packPackagesFor system;
    in
    (mergedSkillsFor system)
    // packsP
    // {
      # Standalone-face aggregate: the all-58 env (the per-group `default`s were
      # dropped above as they each covered only one group).
      default = packsP.agent-skills-daymade-all;
    }
  );

  # Root view: the individual skills plus the named pack envs.
  skillsAndPacks = mapAttrs (
    _: filterAttrs (n: _: hasPrefix "agent-skill-" n || hasPrefix "agent-skills-daymade-" n)
  ) packages;

  # Combinations view: the individual skills only (packs excluded).
  skillsOnly = mapAttrs (_: filterAttrs (n: _: hasPrefix "agent-skill-" n)) (
    forSystems mergedSkillsFor
  );
in
{
  inherit packages;
  vendoredSkills = skillsAndPacks;
  source.packages = skillsOnly;
}
