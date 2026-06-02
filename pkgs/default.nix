# CATEGORY 1 — vendored third-party skills (no upstream Nix flake), each
# self-contained under pkgs/<name>/. This file auto-discovers those subdirs and
# folds their canonical `default.nix` modules into the vendored-category contract
# consumed by the root flake (plain `import`, so it adds no `path:` input —
# keeping Garnix happy when skillspkgs is consumed transitively) and by the
# standalone pkgs/flake.nix face. Adding a vendored skill is a matter of dropping
# a new pkgs/<name>/ directory (default.nix + flake.nix) and adding its source to
# the root's `srcs` map.
#
# Per-module contract — each pkgs/<name>/default.nix is
#   { nixpkgs, flake-skills, src } -> built // {
#     vendoredSkills  = { <system> = { <pkgKey> = <drv>; ... }; };  # root packages.<sys>
#     source.packages = { <system> = { agent-skill-*; ... }; };     # combinations view
#   }
{
  nixpkgs,
  flake-skills,
  # Locked sources, keyed by pkgs/<name> directory name. The root passes its
  # `*-src` flake inputs here; each module slices its own subpath if needed.
  srcs,
}:
let
  inherit (nixpkgs) lib;

  entries = builtins.readDir ./.;
  dirs = lib.filter (name: entries.${name} == "directory") (builtins.attrNames entries);

  modules = lib.listToAttrs (
    map (name: {
      inherit name;
      value = import (./. + "/${name}") {
        inherit nixpkgs flake-skills;
        src = srcs.${name};
      };
    }) dirs
  );
  moduleList = lib.attrValues modules;
in
{
  # Every vendored package surfaced in packages.<sys>, folded across all modules.
  vendoredSkillsFor =
    system: lib.foldl' (acc: m: acc // (m.vendoredSkills.${system} or { })) { } moduleList;

  # Synthetic source flakes (`{ packages.<sys> = { ... }; }`) consumed by the
  # category-3 combinations, keyed by directory name.
  sources = lib.mapAttrs (_: m: m.source) modules;
}
