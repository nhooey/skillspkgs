{
  description = "skillspkgs dev-shell skill set — an isolated sub-flake invoked at RUNTIME by the root devShell, never a root input, so the skill sources live only in THIS flake's lock. It installs the skill-packaging family's skills, as sources/combinations/families.nix names them, plus the whole git-skills and shell-skills collections.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";

    # The builder lib; it carries no skill inputs.
    agent-skill-flake = {
      url = "github:nhooey/agent-skill-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # First-party skill collections, the same repos the root flake
    # aggregates. They follow `nixpkgs` but not `agent-skill-flake`, so each
    # keeps its own compatible builder.
    coding-agent-skills = {
      url = "github:nhooey/coding-agent-skills/overnight-skills";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    document-skills = {
      url = "github:nhooey/document-skills/overnight-skills";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-skills = {
      url = "github:nhooey/git-skills/overnight-skills";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-skills = {
      url = "github:nhooey/nix-skills/overnight-skills";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    python-skills = {
      url = "github:nhooey/python-skills/overnight-skills";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    shell-skills = {
      url = "github:nhooey/shell-skills/overnight-skills";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    writing-skills = {
      url = "github:nhooey/writing-skills/overnight-skills";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Vendored third-party skills, through this repository's own
    # `?dir=pkgs/<name>` faces.
    humanizer = {
      url = "github:nhooey/skillspkgs?dir=pkgs/humanizer";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    skill-creator = {
      url = "github:nhooey/skillspkgs?dir=pkgs/skill-creator";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    superpowers = {
      url = "github:nhooey/skillspkgs?dir=pkgs/superpowers";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      agent-skill-flake,
      ...
    }@inputs:
    agent-skill-flake.lib.mkDevshellSkillsFlake {
      inherit nixpkgs;
      systems = import inputs.systems;
      name = "skillspkgs-devshell";
      envName = "agent-skills-skillspkgs-devshell";
      packagePrefix = "agent-skill-";
      sources = [
        # Headless runs, plans, scratchpad, build limits, and how skills
        # refer to each other.
        {
          source = inputs.coding-agent-skills;
          skills = [
            "coding-agent-headless-in-checkout"
            "coding-agent-plans-as-graph"
            "coding-agent-scratchpad-scripts"
            "coding-agent-session-build-limits"
            "coding-agent-skill-references"
          ];
        }
        # Markdown read in a terminal.
        {
          source = inputs.document-skills;
          skills = [
            "markdown-hygiene-escape-reserved-characters"
            "markdown-hygiene-lists-headings-tables"
            "markdown-hygiene-terminal-rendering"
          ];
        }
        # Commits, branches and pull requests, and the github-policy-* skills.
        { source = inputs.git-skills; }
        # Writing this repository's flakes and bumping their inputs.
        {
          source = inputs.nix-skills;
          skills = [
            "nix-flakes"
            "nix-flake-recursive-bump-input-versions"
          ];
        }
        # The skills' bundled scripts.
        {
          source = inputs.python-skills;
          skills = [
            "python-hygiene-functional-style"
          ];
        }
        # Safe shell commands: named deletes, PIDs, no machine-wide changes.
        { source = inputs.shell-skills; }
        # Prose in skills, READMEs and commit messages.
        {
          source = inputs.writing-skills;
          skills = [
            "writing-hygiene-headings-as-outline"
            "writing-hygiene-prose-to-lists"
            "writing-hygiene-refer-by-canonical-label"
            "writing-hygiene-tables-for-comparison"
          ];
        }
        # Authoring skills.
        { source = inputs.humanizer; }
        {
          source = inputs.skill-creator;
          prefix = "anthropic";
        }
        {
          source = inputs.superpowers;
          prefix = "superpowers";
        }
      ];
    };
}
