{
  description = "superpowers — Claude Code skills from obra/superpowers (workflow / review / integration packs).";

  # NOTE — upstream layout caveat.
  # `flake-skills.lib.mkAllSkillsFlake` ships only SKILL.md, references/,
  # and scripts/ per skill (Anthropic's official agent-skill spec). Several
  # obra/superpowers skills carry loose top-level companion files outside
  # that whitelist — e.g. systematic-debugging's condition-based-waiting.md /
  # root-cause-tracing.md, test-driven-development's testing-anti-patterns.md,
  # writing-skills' anthropic-best-practices.md + persuasion-principles.md.
  # The core SKILL.md prose still works; the dropped files are referenced
  # for deeper context. To ship them, extend flake-skills with an
  # `extraFiles` knob (analogous to `extraDirs`) and bump the rev.

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-skills.url = "github:nhooey/flake-skills";
    flake-skills.inputs.nixpkgs.follows = "nixpkgs";
    superpowers-src = {
      url = "github:obra/superpowers";
      flake = false;
    };
  };

  outputs =
    { nixpkgs, flake-skills, superpowers-src, ... }:
    let
      base = flake-skills.lib.mkAllSkillsFlake {
        inherit nixpkgs;
        skillsDir = "${superpowers-src}/skills";
        packagePrefix = "agent-skill-";
      };

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forSystems = nixpkgs.lib.genAttrs systems;

      packs = {
        # All 14 skills as a single mkSkillsEnv. Same content as base's
        # `all` symlinkJoin, but with passthru.isFlakeSkillsEnv so the
        # home-manager module can expand it back into per-skill records on
        # activation.
        agent-skills-superpowers-all = [
          "brainstorming"
          "writing-plans"
          "writing-skills"
          "executing-plans"
          "subagent-driven-development"
          "dispatching-parallel-agents"
          "using-superpowers"
          "test-driven-development"
          "systematic-debugging"
          "requesting-code-review"
          "receiving-code-review"
          "verification-before-completion"
          "finishing-a-development-branch"
          "using-git-worktrees"
        ];

        # Workflow & planning — what to do before coding.
        agent-skills-superpowers-workflow = [
          "brainstorming"
          "writing-plans"
          "writing-skills"
          "executing-plans"
          "subagent-driven-development"
          "dispatching-parallel-agents"
          "using-superpowers"
        ];

        # Development & review — how to write and evaluate code.
        agent-skills-superpowers-review = [
          "test-driven-development"
          "systematic-debugging"
          "requesting-code-review"
          "receiving-code-review"
        ];

        # Finishing & integration — verifying, merging, isolating worktrees.
        agent-skills-superpowers-integration = [
          "verification-before-completion"
          "finishing-a-development-branch"
          "using-git-worktrees"
        ];
      };

      mkEnv =
        system: packName: skillNames:
        flake-skills.lib.mkSkillsEnv {
          pkgs = nixpkgs.legacyPackages.${system};
          name = packName;
          skills = builtins.map (n: base.packages.${system}."agent-skill-${n}") skillNames;
        };

      packPackages = forSystems (
        system: nixpkgs.lib.mapAttrs (packName: skillNames: mkEnv system packName skillNames) packs
      );
    in
    base
    // {
      packages = nixpkgs.lib.recursiveUpdate base.packages packPackages;
    };
}
