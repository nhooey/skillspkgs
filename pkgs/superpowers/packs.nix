# Canonical superpowers pack definitions (skill-name lists). Single source of
# truth, imported by ./build.nix and (transitively, via that build) by the root
# flake's sources/vendored.nix. Edit pack membership here and nowhere else.
{
  # All 14 skills as a single mkSkillsEnv. Same content as base's `all`
  # symlinkJoin, but with passthru.isFlakeSkillsEnv so the home-manager module
  # can expand it back into per-skill records on activation.
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
}
