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
        # The daymade skill-creation pack (see pkgs/daymade/packs.nix —
        # `agent-skills-daymade-skill-creation`, the source of truth for
        # membership). No `prefix` here: pkgs/daymade renames every skill to
        # `daymade-<name>` at vendoring time, so the cherry-pick names are the
        # already-prefixed identities and a `prefix = "daymade"` would double it
        # to `daymade-daymade-*`.
        source = vendoredSources.daymade;
        skills = [
          "daymade-skill-creator"
          "daymade-skill-reviewer"
          "daymade-skills-search"
          "daymade-claude-skills-troubleshooting"
          "daymade-claude-md-progressive-disclosurer"
        ];
      }
    ];
  };
in
{
  reconcileScriptFor = authoring.reconcileScript;
  combinations.authoring = authoring;
}
