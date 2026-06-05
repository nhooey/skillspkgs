# The `authoring-with-git` combination — the `authoring` set plus the whole
# git/GitHub pack, i.e. the full skill set a skills-authoring repo installs into
# its dev shell. It splices the `authoring` combination in AS A SOURCE (its
# `packages` make it re-composable), so the curated authoring set stays defined
# once, in authoring.nix, and this file only adds git-skills on top.
#
# `git-skills` is a live category-2 input; the other args are forwarded to
# `authoring.nix` unchanged. `name` is the distinct reconcile-ownership appName.
itemArgs@{
  nixpkgs,
  agent-skill-flake,
  systems,
  git-skills,
  ...
}:
let
  authoring = (import ./authoring.nix itemArgs).combinations.authoring;

  authoringWithGit = agent-skill-flake.lib.mkCombination {
    inherit nixpkgs systems;
    name = "skillspkgs-authoring-with-git";
    envName = "agent-skills-authoring-with-git";
    packagePrefix = "agent-skill-";
    sources = [
      { source = authoring; }
      { source = git-skills; }
    ];
  };
in
{
  reconcileScriptFor = authoringWithGit.reconcileScript;
  combinations.authoring-with-git = authoringWithGit;
}
