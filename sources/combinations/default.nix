# CATEGORY 3 — cross-cutting combinations: curated unions of skills already
# provided by categories 1 and 2, built inline via mkAggregateSkillsFlake and
# exposed under a `combinations.<name>` output (kept OUT of packages.<sys>).
#
# This default.nix auto-discovers and folds the sibling per-combination files
# (authoring.nix, …) — adding a combination is a matter of dropping a new
# `<name>.nix` file beside this one, no edits here.
#
# Imported as a plain Nix file by the root flake — NOT a flake input. The sibling
# flake.nix exists only for standalone `?dir=sources/combinations` use.
#
# Per-item contract — each `<name>.nix` is `itemArgs -> {`
#   reconcileScriptFor = system: "<shell snippet>";
#   combinations       = { <name> = forSystems (system: { reconcileScript; apps; env; }); };
# `}`. `vendored` is sources/vendored's result; `skills-nix` is a live category-2
# input.
{
  nixpkgs,
  flake-skills,
  forSystems,
  systems,
  skills-nix,
  vendored,
}:
let
  inherit (nixpkgs) lib;

  itemArgs = {
    inherit
      nixpkgs
      flake-skills
      forSystems
      systems
      skills-nix
      vendored
      ;
  };

  # Auto-discover sibling per-combination `.nix` files (single-level readDir).
  entries = builtins.readDir ./.;
  itemFiles = lib.filter (
    name:
    entries.${name} == "regular"
    && lib.hasSuffix ".nix" name
    && name != "default.nix"
    && name != "flake.nix"
  ) (builtins.attrNames entries);

  items = map (name: import (./. + "/${name}") itemArgs) itemFiles;
in
{
  # Merge every combination's `combinations` attrset (disjoint named keys).
  combinations = lib.foldl' (acc: item: acc // item.combinations) { } items;

  # Compose every combination's reconcile script for a given system into one
  # shell snippet. Each combination owns a distinct reconcile appName, so running
  # them in sequence is safe and idempotent.
  reconcileScriptFor =
    system: lib.concatStringsSep "\n" (map (item: item.reconcileScriptFor system) items);
}
