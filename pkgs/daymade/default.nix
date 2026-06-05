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
# `source = { owner = "daymade"; }` namespaces every package key as
# `agent-skill-daymade-<name>`, which keeps daymade's skill-creator from
# colliding with anthropics/skills' in the root package set. The installed
# skill name stays bare. `renameFn` only lowercases — daymade ships one
# uppercase dir, iOS-APP-developer, which would fail Claude Code's
# ^[a-z0-9-]{1,64}$ name rule otherwise.
{
  nixpkgs,
  agent-skill-flake,
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

  renameFn = ctx: toLower ctx.name;

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
    agent-skill-flake.lib.mkAllSkillsFlake {
      inherit nixpkgs renameFn;
      source = {
        owner = "daymade";
      };
      skillsDir = if dir == "." then "${src}" else "${src}/${dir}";
      packagePrefix = "agent-skill-";
    };

  groups = map buildGroup groupDirs;

  # Systems the whole flake targets, taken from the groups themselves rather than
  # restating a platform list (mkAllSkillsFlake fans out over nix-systems/default).
  forSystems = genAttrs (builtins.attrNames (builtins.head groups).packages);

  # Each group's `packages.<sys>` carries its own `default` /
  # `agent-skills-daymade-all` aggregate (covering only that group); drop both
  # before merging so the union is exactly the `agent-skill-daymade-*` per-skill
  # keys. The canonical all-58 `agent-skills-daymade-all` pack is rebuilt from
  # ./packs.nix below.
  dropAggregates =
    pkgs:
    removeAttrs pkgs [
      "default"
      "agent-skills-daymade-all"
    ];

  mergedSkillsFor = system: foldl' (acc: g: acc // dropAggregates g.packages.${system}) { } groups;

  packs = import ./packs.nix;

  # Each group exposes `bySkillName` (per-skill drvs keyed by bare installed
  # name); merge them across the root + suites into one index.
  mergedByName = system: foldl' (acc: g: acc // g.bySkillName.${system}) { } groups;

  # Pack lists hold pre-rename directory names; `toLower` matches the
  # lowercased installed name (iOS-APP-developer -> ios-app-developer).
  mkEnv =
    system: packName: skillNames:
    agent-skill-flake.lib.mkSkillsEnv {
      pkgs = nixpkgs.legacyPackages.${system};
      name = packName;
      skills = map (n: (mergedByName system).${toLower n}) skillNames;
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

  # The individual skills plus the named pack envs — shared by the root
  # package set and the combinations source view. The packs are exposed to
  # combinations too so a combination can select a pack's members via the
  # `pack` source field; the cherry-pick filters by the singular
  # `agent-skill-` prefix, so the plural `agent-skills-*` pack keys never
  # leak into skill selection.
  skillsAndPacks = mapAttrs (
    _: filterAttrs (n: _: hasPrefix "agent-skill-" n || hasPrefix "agent-skills-daymade-" n)
  ) packages;
in
{
  inherit packages;
  vendoredSkills = skillsAndPacks;
  source.packages = skillsAndPacks;
}
