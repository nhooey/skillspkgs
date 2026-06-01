# CATEGORY 3 — cross-cutting combinations: curated unions of skills already
# provided by categories 1 and 2, built inline via mkAggregateSkillsFlake and
# exposed under a `combinations.<name>` output (kept OUT of packages.<sys>).
#
# `vendored` is sources/vendored.nix's result — its synthetic `sources` feed
# the category-1 skills in here; `skills-nix` is the live category-2 input.
{
  nixpkgs,
  flake-skills,
  forSystems,
  systems,
  skills-nix,
  vendored,
}:
let
  # The `authoring` combination — skills installed when authoring a skills repo.
  # Mirrors skills-git/skills-authoring exactly (same four sources, cherry-pick,
  # and prefixes); `name` is the distinct reconcile-ownership appName.
  authoringAgg = flake-skills.lib.mkAggregateSkillsFlake {
    inherit nixpkgs systems;
    name = "skillspkgs-authoring";
    packagePrefix = "agent-skill-";
    sources = [
      {
        source = skills-nix;
        skills = [
          "nix-flakes"
          "nix-garnix-ci"
        ];
      }
      { source = vendored.sources.humanizer; }
      {
        source = vendored.sources.skillCreator;
        prefix = "anthropic";
      }
      {
        source = vendored.sources.superpowers;
        prefix = "superpowers";
      }
    ];
  };

  # A single env package for home-manager consumers, drawn from the aggregate's
  # already-prefixed package set (mkSkillsEnv does not re-prefix).
  authoringEnv =
    system:
    flake-skills.lib.mkSkillsEnv {
      pkgs = nixpkgs.legacyPackages.${system};
      name = "agent-skills-authoring";
      skills = builtins.attrValues (
        nixpkgs.lib.filterAttrs (
          n: _: nixpkgs.lib.hasPrefix "agent-skill-" n
        ) authoringAgg.packages.${system}
      );
    };
in
{
  # The declarative reconcile one-liner the root devshell runs on `nix develop`.
  reconcileScriptFor = authoringAgg.reconcileScript;

  combinations.authoring = forSystems (system: {
    reconcileScript = authoringAgg.reconcileScript system;
    apps = authoringAgg.apps.${system};
    env = authoringEnv system;
  });
}
