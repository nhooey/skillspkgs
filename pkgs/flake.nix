{
  description = "skillspkgs vendored category — third-party Claude Code skills with no upstream Nix flake (caveman, clojure-skills, daymade, humanizer, malli, opinionated-software-engineering, rust-best-practices, shadow-cljs, skill-creator, superpowers, trailofbits, typescript-strict, update-changelog).";

  # Standalone `?dir=pkgs` face for the whole vendored category. The root flake
  # never reads this — it plain-`import`s ./default.nix (see that file's header).
  # These inputs + flake.lock pin the category for direct `?dir=pkgs` use and back
  # the combinations standalone face (sources/combinations/flake.nix). Individual
  # skills also have their own thinner `?dir=pkgs/<name>` faces.
  #
  # The `srcs` map comes from ./srcs.nix, shared with the root flake, so these
  # inputs must declare every `*-src` input it names.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    agent-skill-flake = {
      url = "github:nhooey/agent-skill-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agent-stuff-src = {
      url = "github:mitsuhiko/agent-stuff";
      flake = false;
    };
    anthropics-skills-src = {
      url = "github:anthropics/skills";
      flake = false;
    };
    apollographql-skills-src = {
      url = "github:apollographql/skills";
      flake = false;
    };
    caveman-src = {
      url = "github:JuliusBrussee/caveman";
      flake = false;
    };
    citypaul-dotfiles-src = {
      url = "github:citypaul/.dotfiles";
      flake = false;
    };
    clojure-malli-skill-src = {
      url = "github:stoating/clojure-malli-skill";
      flake = false;
    };
    clojure-shadow-cljs-skill-src = {
      url = "github:stoating/clojure-shadow-cljs-skill";
      flake = false;
    };
    clojure-skills-src = {
      url = "github:chaploud/clojure-skills";
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
      ...
    }@inputs:
    let
      forSystems = nixpkgs.lib.genAttrs (import systems);
      vendored = import ./default.nix {
        inherit nixpkgs agent-skill-flake;
        srcs = import ./srcs.nix inputs;
      };
    in
    {
      packages = forSystems (system: vendored.vendoredSkillsFor system);

      # Non-standard output: the synthetic source flakes, so the combinations
      # standalone face (sources/combinations/flake.nix) can read `vendored.sources`.
      inherit (vendored) sources;
    };
}
