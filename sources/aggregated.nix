# CATEGORY 2 — first-party repos that ship their own Nix flake.
#
# Every input not listed in `infrastructureInputs` (passed in from the root,
# which is where the input declarations must live) is treated as an aggregated
# downstream repo; this module merges their `packages` / `legacyPackages`
# outputs into the root flake's, per system.
{
  nixpkgs,
  inputs,
  infrastructureInputs,
}:
let
  aggregatedInputs = builtins.removeAttrs inputs infrastructureInputs;

  # Strip `default` before merging so one input's `default` doesn't silently
  # shadow another's. Single-package flakes that only expose `default` are
  # promoted to the input's name instead.
  aggregatorMetaKeys = [ "default" ];
  stripAggregatorMeta = attrs: builtins.removeAttrs attrs aggregatorMetaKeys;
in
{
  aggregatedFor =
    field: system:
    nixpkgs.lib.foldl' (
      acc: name:
      let
        attrs = aggregatedInputs.${name}.${field}.${system} or { };
        named = stripAggregatorMeta attrs;
        promoted = if attrs ? default && named == { } then { ${name} = attrs.default; } else { };
      in
      acc // promoted // named
    ) { } (builtins.attrNames aggregatedInputs);
}
