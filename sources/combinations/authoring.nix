# The `authoring` combination — skills installed when authoring a skills repo.
# A curated cross-cut of skill-authoring tooling (nix, humanizer, anthropic
# skill-creation, superpowers), each cherry-picked and/or prefixed;
# `name` is the distinct reconcile-ownership appName.
#
# `vendoredSources` is an attrset (skill-name -> a `{ packages.<sys> = …; }`
# source) supplied by the caller — the root flake passes its in-memory
# `vendored.sources`; the standalone `?dir=` face passes three `github:?dir=pkgs/*`
# faces. `nix-skills` is the live category-2 input; `nixSkillNames` cherry-picks
# from it, and a splicing combination may narrow it.
{
  nixpkgs,
  agent-skill-flake,
  systems,
  nix-skills,
  vendoredSources,
  nixSkillNames ? [
    "nix-flakes"
  ],
  ...
}:
let
  authoring = agent-skill-flake.lib.mkCombination {
    inherit nixpkgs systems;
    name = "skillspkgs-authoring";
    envName = "agent-skills-authoring";
    packagePrefix = "agent-skill-";
    sources = [
      {
        source = nix-skills;
        skills = nixSkillNames;
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
