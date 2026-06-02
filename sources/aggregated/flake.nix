{
  description = "skillspkgs aggregated category — merges first-party nhooey repos that ship their own Nix flake.";

  # Standalone `?dir=sources/aggregated` face only. The root flake never reads
  # this — it plain-`import`s ./default.nix, passing its own (much larger) input
  # set. Here we re-declare the category-2 repos explicitly so the fold has
  # something concrete to merge and `?dir=` stays buildable + self-documenting.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    flake-skills = {
      url = "github:nhooey/flake-skills";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    coding-agent-skills = {
      url = "github:nhooey/coding-agent-skills";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-skills.follows = "flake-skills";
    };
    nix-gstack = {
      url = "github:nhooey/nix-gstack";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    skills-git = {
      url = "github:nhooey/skills-git";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-skills.follows = "flake-skills";
    };
    skills-nix = {
      url = "github:nhooey/skills-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-skills.follows = "flake-skills";
    };
  };

  outputs =
    { nixpkgs, systems, ... }@inputs:
    let
      forSystems = nixpkgs.lib.genAttrs (import systems);
      aggregated = import ./default.nix {
        inherit nixpkgs inputs;
        # `systems` powers the fanout, not a downstream repo to aggregate, so it
        # joins the infrastructure set the fold removes before merging.
        infrastructureInputs = [
          "self"
          "nixpkgs"
          "systems"
          "flake-skills"
        ];
      };
    in
    {
      packages = forSystems (system: aggregated.aggregatedFor "packages" system);
      legacyPackages = forSystems (system: aggregated.aggregatedFor "legacyPackages" system);
    };
}
