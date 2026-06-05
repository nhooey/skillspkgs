# The `authoring-with-git` combination — the `authoring` set plus the whole
# git/GitHub pack, i.e. the full skill set a skills-authoring repo installs into
# its dev shell. It splices the `authoring` combination in AS A SOURCE (its
# `packages` make it re-composable), so the curated authoring set stays defined
# once, in authoring.nix, and this file only adds skills-git on top.
#
# `skills-git` is a live category-2 input; the other args are forwarded to
# `authoring.nix` unchanged. `name` is the distinct reconcile-ownership appName.
itemArgs@{
  nixpkgs,
  flake-skills,
  systems,
  skills-git,
  ...
}:
let
  authoring = (import ./authoring.nix itemArgs).combinations.authoring;

  authoringWithGit = flake-skills.lib.mkCombination {
    inherit nixpkgs systems;
    name = "skillspkgs-authoring-with-git";
    envName = "agent-skills-authoring-with-git";
    packagePrefix = "agent-skill-";
    sources = [
      { source = authoring; }
      { source = skills-git; }
    ];
  };
in
{
  reconcileScriptFor = authoringWithGit.reconcileScript;
  combinations.authoring-with-git = authoringWithGit;
}
