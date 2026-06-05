{
  description = "skillspkgs dev-shell skill set — an isolated sub-flake invoked at RUNTIME by the root devShell, never a root input. The dev-shell set (skillspkgs' own authoring-with-git combination) lives only in THIS flake's lock. skillspkgs still aggregates its skill sources for its package outputs; only the dev-shell install moved off the root.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";

    # `agent-skill-flake` is the builder library, not a skill — it provides
    # `mkDevshellSkillsFlake`. Followed by the skill source below so the whole
    # tree shares one evaluation.
    agent-skill-flake = {
      url = "github:nhooey/agent-skill-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # skillspkgs' own curated `authoring-with-git` combination, consumed
    # through its standalone `?dir=sources/combinations` face. The dev shell
    # dogfoods the published combination rather than rebuilding it from the
    # root's inputs.
    skillspkgs-combinations = {
      url = "github:nhooey/skillspkgs?dir=sources/combinations";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        agent-skill-flake.follows = "agent-skill-flake";
      };
    };
  };

  outputs =
    {
      nixpkgs,
      agent-skill-flake,
      skillspkgs-combinations,
      ...
    }@inputs:
    agent-skill-flake.lib.mkDevshellSkillsFlake {
      inherit nixpkgs;
      systems = import inputs.systems;
      name = "skillspkgs-devshell";
      envName = "agent-skills-skillspkgs-devshell";
      packagePrefix = "agent-skill-";
      sources = [
        { source = skillspkgs-combinations.combinations.authoring-with-git; }
      ];
    };
}
