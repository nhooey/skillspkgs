# CATEGORY 1 — vendored third-party skills (no upstream Nix flake).
#
# The per-source build logic + pack data live canonically under pkgs/<name>/
# (also consumed standalone via `github:nhooey/skillspkgs?dir=pkgs/<name>`); the
# per-item files here (humanizer.nix, skill-creator.nix, superpowers.nix) import
# those build files and assemble each into the vendored contract. This default.nix
# auto-discovers and folds them — adding a vendored skill is a matter of dropping
# a new `<name>.nix` file beside this one, no edits here.
#
# Imported as a plain Nix file by the root flake — NOT a flake input — so it adds
# no `path:` input, keeping Garnix happy when skillspkgs is consumed transitively.
# The sibling flake.nix exists only for standalone `?dir=sources/vendored` use.
#
# Per-item contract — each `<name>.nix` is `itemArgs -> {`
#   vendoredSkillsFor = system: { <pkgKey> = <drv>; ... };  # 0..N packages.<sys> keys
#   sources           = { <sourceKey> = { packages = forSystems (...); }; };
# `}`. `sources` feeds the category-3 combinations (mkAggregateSkillsFlake reads a
# source only through `source.packages.<system>`); keys are file-namespaced so the
# fold never collides.
{
  nixpkgs,
  flake-skills,
  forSystems,
  humanizer-src,
  anthropics-skills-src,
  superpowers-src,
}:
let
  inherit (nixpkgs) lib;

  # Threaded verbatim into every per-item file.
  itemArgs = {
    inherit
      nixpkgs
      flake-skills
      forSystems
      humanizer-src
      anthropics-skills-src
      superpowers-src
      ;
  };

  # Auto-discover sibling per-item `.nix` files (single-level readDir — no
  # recursion). The `"regular"` guard drops flake.lock and any future subdir;
  # excluding default.nix prevents self-import.
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
  # Every vendored package surfaced in packages.<sys>, folded across all items.
  vendoredSkillsFor = system: lib.foldl' (acc: item: acc // item.vendoredSkillsFor system) { } items;

  # Synthetic source flakes (`{ packages.<sys> = { ... }; }`) consumed by the
  # category-3 combinations, folded across all items.
  sources = lib.foldl' (acc: item: acc // item.sources) { } items;
}
