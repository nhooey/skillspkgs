# The `authoring` combination — skills installed when authoring a skills repo.
# A curated cross-cut of skill-authoring tooling (nix, humanizer, anthropic +
# daymade skill-creation, superpowers), each cherry-picked and/or prefixed;
# `name` is the distinct reconcile-ownership appName.
#
# `vendoredSources` is an attrset (skill-name -> a `{ packages.<sys> = …; }`
# source) supplied by the caller — the root flake passes its in-memory
# `vendored.sources`; the standalone `?dir=` face passes four `github:?dir=pkgs/*`
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
      {
        # The daymade skill-creation pack, selected by its bundle so its
        # membership stays the single source of truth (pkgs/daymade/packs.nix).
        # `prefix` brands the installed skill names `daymade-*`, parallel to
        # anthropic's.
        source = vendoredSources.daymade;
        pack = "agent-skills-daymade-skill-creation";
        prefix = "daymade";
      }
    ];
  };
in
{
  reconcileScriptFor = authoring.reconcileScript;
  combinations.authoring = authoring;
}
