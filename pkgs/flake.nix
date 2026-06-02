{
  description = "skillspkgs vendored category — third-party Claude Code skills with no upstream Nix flake (humanizer, skill-creator, superpowers).";

  # Standalone `?dir=pkgs` face for the whole vendored category. The root flake
  # never reads this — it plain-`import`s ./default.nix (see that file's header).
  # These inputs + flake.lock pin the category for direct `?dir=pkgs` use and back
  # the combinations standalone face (sources/combinations/flake.nix). Individual
  # skills also have their own thinner `?dir=pkgs/<name>` faces.
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
        inherit nixpkgs flake-skills;
        srcs = {
          humanizer = humanizer-src;
          "skill-creator" = anthropics-skills-src;
          superpowers = superpowers-src;
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
