# One combination per repository family, plus the `base` combination every
# family includes. A repository's skills dev shell takes its family's
# combination as its one source and adds a source of its own only for a
# language or tool the rest of its family doesn't use (e.g. the Clojure
# skills in a Clojure repository, `python-hygiene-functional-style` in a
# Python-first one outside the skill families).
#
# The families are those of the cross-repository plan:
#
#   skill-collections                 base + skill authoring
#   skill-packaging                   skill-collections + input bumping
#   nix-tooling                       base + input bumping + shipped defaults
#                                     + changelogs
#   claude-code-tools                 base + shipped defaults + changelogs
#                                     + strict TypeScript
#   applications                      base + shipped defaults + changelogs
#   browser-extensions-and-game-mods  base
#   configuration                     base + GitHub policy + input bumping
#   content                           base
#
# Every first-party pick is a list of skill names, so a combination holds
# exactly the skills named here: a new skill in a collection joins a family
# only when it is added below, and a name a collection no longer has is an
# evaluation error. Vendored sources are single skills, or (humanizer,
# skill-creator, superpowers) the authoring set taken whole, as
# `authoring.nix` takes it. Families splice `base` (or another family) in as a source, so each
# shared set is defined once.
#
# `skillSources` holds the category-2 repos by input name and
# `vendoredSources` the category-1 sources by pkgs/ directory name.
{
  nixpkgs,
  agent-skill-flake,
  systems,
  skillSources,
  vendoredSources,
  ...
}:
let
  inherit (nixpkgs) lib;

  mk =
    name: sources:
    agent-skill-flake.lib.mkCombination {
      inherit nixpkgs systems sources;
      name = "skillspkgs-${name}";
      envName = "agent-skills-${name}";
      packagePrefix = "agent-skill-";
    };

  pick = repo: skills: {
    source = skillSources.${repo};
    inherit skills;
  };

  base = mk "base" [
    (pick "coding-agent-skills" [
      "coding-agent-headless-in-checkout"
      "coding-agent-plans-as-graph"
      "coding-agent-scratchpad-scripts"
      "coding-agent-session-build-limits"
    ])
    (pick "document-skills" [
      "markdown-hygiene-escape-reserved-characters"
      "markdown-hygiene-lists-headings-tables"
      "markdown-hygiene-terminal-rendering"
    ])
    (pick "git-skills" [
      "git-hygiene-avoid-sweeping-operations"
      "git-hygiene-branch-naming"
      "git-hygiene-commit-message-format"
      "git-hygiene-conventional-commits"
      "git-hygiene-gitignore"
      "git-hygiene-no-history-in-tracked-files"
      "git-hygiene-push-force-safely"
      "git-hygiene-ssh-remotes"
      "git-workflow-curate-unpushed"
      "git-workflow-inspect-before-commit"
      "git-workflow-push-mode"
      "git-workflow-tidy-branches"
      "github-hygiene-gh-cli-gotchas"
      "github-hygiene-pull-request-mirrors-commit"
      "github-hygiene-refer-to-issues-and-pull-requests"
      "github-workflow-browser-draft-preview"
      "github-workflow-pull-request-changeset-prompt"
      "github-workflow-pull-request-stacked"
      "github-workflow-pull-request-status-line"
      "github-workflow-pull-request-watcher"
      "github-workflow-repo-activity"
    ])
    (pick "nix-skills" [
      "nix-flakes"
    ])
    (pick "shell-skills" [
      "shell-hygiene-commands-as-cli-tools"
      "shell-hygiene-delete-named-paths"
      "shell-hygiene-long-options"
      "shell-hygiene-no-machine-wide-changes"
      "shell-hygiene-secrets-through-secretspec"
      "shell-hygiene-symbolic-permission-modes"
      "shell-hygiene-target-processes-by-pid"
    ])
    (pick "writing-skills" [
      "writing-hygiene-headings-as-outline"
      "writing-hygiene-prose-to-lists"
      "writing-hygiene-refer-by-canonical-label"
      "writing-hygiene-tables-for-comparison"
    ])
  ];

  inputBumping = pick "nix-skills" [
    "nix-flake-recursive-bump-input-versions"
  ];

  shippedDefaults = pick "software-design-skills" [
    "config-hygiene-shipped-defaults"
  ];

  changelogs = {
    source = vendoredSources."update-changelog";
  };

  skillCollections = mk "skill-collections" [
    { source = base; }
    (pick "coding-agent-skills" [
      "coding-agent-skill-references"
    ])
    (pick "python-skills" [
      "python-hygiene-functional-style"
    ])
    { source = vendoredSources.humanizer; }
    {
      source = vendoredSources."skill-creator";
      prefix = "anthropic";
    }
    {
      source = vendoredSources.superpowers;
      prefix = "superpowers";
    }
  ];

  families = {
    inherit base;
    skill-collections = skillCollections;
    skill-packaging = mk "skill-packaging" [
      { source = skillCollections; }
      inputBumping
    ];
    nix-tooling = mk "nix-tooling" [
      { source = base; }
      inputBumping
      shippedDefaults
      changelogs
    ];
    claude-code-tools = mk "claude-code-tools" [
      { source = base; }
      shippedDefaults
      changelogs
      { source = vendoredSources."typescript-strict"; }
    ];
    applications = mk "applications" [
      { source = base; }
      shippedDefaults
      changelogs
    ];
    browser-extensions-and-game-mods = mk "browser-extensions-and-game-mods" [
      { source = base; }
    ];
    configuration = mk "configuration" [
      { source = base; }
      inputBumping
      (pick "git-skills" [
        "github-policy-auto-delete-merged-branches"
        "github-policy-codeowners"
        "github-policy-merge-commits-only"
        "github-policy-protect-default-branch"
      ])
    ];
    content = mk "content" [
      { source = base; }
    ];
  };
in
{
  reconcileScriptFor =
    system: lib.concatStringsSep "\n" (lib.mapAttrsToList (_: c: c.reconcileScript system) families);
  combinations = families;
}
