# The `authoring` combination — skills installed when authoring a skills repo.
# Mirrors skills-git/skills-authoring exactly (same four sources, cherry-pick,
# and prefixes); `name` is the distinct reconcile-ownership appName.
#
# `vendoredSources` is an attrset (skill-name -> a `{ packages.<sys> = …; }`
# source) supplied by the caller — the root flake passes its in-memory
# `vendored.sources`; the standalone `?dir=` face passes three `github:?dir=pkgs/*`
# faces. `skills-nix` is the live category-2 input.
{
  nixpkgs,
  flake-skills,
  forSystems,
  systems,
  skills-nix,
  vendoredSources,
  ...
}:
let
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
      { source = vendoredSources.humanizer; }
      {
        source = vendoredSources."skill-creator";
        prefix = "anthropic";
      }
      {
        source = vendoredSources.superpowers;
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
  reconcileScriptFor = authoringAgg.reconcileScript;

  combinations.authoring = forSystems (system: {
    reconcileScript = authoringAgg.reconcileScript system;
    apps = authoringAgg.apps.${system};
    env = authoringEnv system;
  });
}
