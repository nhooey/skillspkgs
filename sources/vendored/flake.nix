{
  description = "skillspkgs vendored category — third-party Claude Code skills with no upstream Nix flake (humanizer, skill-creator, superpowers).";

  # Standalone `?dir=sources/vendored` face only. The root flake never reads this
  # — it plain-`import`s ./default.nix (see that file's header). These inputs +
  # flake.lock pin the category for direct `github:nhooey/skillspkgs?dir=…` use.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    flake-skills = {
      url = "github:nhooey/flake-skills";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    anthropics-skills-src = {
      url = "github:anthropics/skills";
      flake = false;
    };
    humanizer-src = {
      url = "github:blader/humanizer";
      flake = false;
    };
    superpowers-src = {
      url = "github:obra/superpowers";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      systems,
      flake-skills,
      anthropics-skills-src,
      humanizer-src,
      superpowers-src,
      ...
    }:
    let
      forSystems = nixpkgs.lib.genAttrs (import systems);
      vendored = import ./default.nix {
        inherit
          nixpkgs
          flake-skills
          forSystems
          anthropics-skills-src
          humanizer-src
          superpowers-src
          ;
      };
    in
    {
      packages = forSystems (system: vendored.vendoredSkillsFor system);

      # Non-standard output: the synthetic source flakes, so the combinations
      # standalone face (sources/combinations/flake.nix) can read `vendored.sources`.
      inherit (vendored) sources;
    };
}
