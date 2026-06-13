{
  description = "skillspkgs vendored category — third-party Claude Code skills with no upstream Nix flake (caveman, daymade, humanizer, opinionated-software-engineering, skill-creator, superpowers, trailofbits).";

  # Standalone `?dir=pkgs` face for the whole vendored category. The root flake
  # never reads this — it plain-`import`s ./default.nix (see that file's header).
  # These inputs + flake.lock pin the category for direct `?dir=pkgs` use and back
  # the combinations standalone face (sources/combinations/flake.nix). Individual
  # skills also have their own thinner `?dir=pkgs/<name>` faces.
  #
  # The `srcs` map below must name EVERY pkgs/<name>/ subdirectory: default.nix
  # auto-discovers them by `readDir` and folds each (forcing `srcs.<name>`), so a
  # missing entry breaks `vendoredSkillsFor` with `attribute '<name>' missing`.
  # Keep it in sync with the root flake's `srcs` map when adding a wrapper.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    agent-skill-flake = {
      url = "github:nhooey/agent-skill-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    anthropics-skills-src = {
      url = "github:anthropics/skills";
      flake = false;
    };
    caveman-src = {
      url = "github:JuliusBrussee/caveman";
      flake = false;
    };
    daymade-skills-src = {
      url = "github:daymade/claude-code-skills";
      flake = false;
    };
    humanizer-src = {
      url = "github:blader/humanizer";
      flake = false;
    };
    opinionated-claude-skills-src = {
      url = "github:Pyroxin/opinionated-claude-skills";
      flake = false;
    };
    superpowers-src = {
      url = "github:obra/superpowers";
      flake = false;
    };
    trailofbits-skills-src = {
      url = "github:trailofbits/skills";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      systems,
      agent-skill-flake,
      anthropics-skills-src,
      caveman-src,
      daymade-skills-src,
      humanizer-src,
      opinionated-claude-skills-src,
      superpowers-src,
      trailofbits-skills-src,
      ...
    }:
    let
      forSystems = nixpkgs.lib.genAttrs (import systems);
      vendored = import ./default.nix {
        inherit nixpkgs agent-skill-flake;
        srcs = {
          caveman = caveman-src;
          daymade = daymade-skills-src;
          humanizer = humanizer-src;
          "opinionated-software-engineering" = opinionated-claude-skills-src;
          "skill-creator" = anthropics-skills-src;
          superpowers = superpowers-src;
          trailofbits = trailofbits-skills-src;
        };
      };
    in
    {
      packages = forSystems (system: vendored.vendoredSkillsFor system);

      # Non-standard output: the synthetic source flakes, so the combinations
      # standalone face (sources/combinations/flake.nix) can read `vendored.sources`.
      inherit (vendored) sources;
    };
}
