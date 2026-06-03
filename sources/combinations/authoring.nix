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
  systems,
  skills-nix,
  vendoredSources,
  ...
}:
let
  authoring = flake-skills.lib.mkCombination {
    inherit nixpkgs systems;
    name = "skillspkgs-authoring";
    envName = "agent-skills-authoring";
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
in
{
  reconcileScriptFor = authoring.reconcileScript;
  combinations.authoring = authoring;
}
