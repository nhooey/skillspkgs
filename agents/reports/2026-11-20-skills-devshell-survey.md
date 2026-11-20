---
state: current
as-of: skillspkgs bd1b085
---

# Survey of the skills dev shells' combinations

47 repositories have a `skills-devshell/flake.nix`. No root `flake.nix` holds dev-shell skill sources. About 25 directories have no `origin` remote at all (for example `browsicle`, `claude-ui-tweaks`, `credentinel`) and were not surveyed.

Skill counts are read off the `.nix` text; nothing was evaluated with Nix. Refs are as each checkout last fetched them, with skillspkgs at `bd1b085`.

## Survey table

| Repository | Combination | Extra sources and skills |
| --- | --- | --- |
| agent-output-skills, clojure-skills, coding-agent-skills, data-skills, document-skills, financial-forensics-skills, git-skills, legal-skills, macos-skills, media-corpus-skills, nix-microsoft-skills, nix-skills, python-skills, shell-skills, skill-authoring-skills, software-design-skills, writing-skills, xtdb-skills (18) | `skill-collections` | none |
| mynixos-legacy-skills | `skill-collections` | coding-agent-skills: `coding-agent-browser-selection` |
| agent-plugins-nixpkgs, agent-skill-flake, legal-skills-nix, nix-gstack, skillspkgs (5) | `skill-packaging` | none |
| nur-packages, swiftpm-nix | `nix-tooling` | none |
| nix-cljfmt | `nix-tooling` | nix-skills: `nix-clojure` |
| nix-github-actions-cache-bench | `nix-tooling` | python-skills: `python-hygiene-functional-style`; nix-skills: `nix-clojure` |
| nix-jetbrains-project-setup, orbstack-machine-nixos-flakes | `nix-tooling` | python-skills: `python-hygiene-functional-style` |
| claffeinate, claude-code-terminal-width | `claude-code-tools` | none |
| agentree-statusline | `claude-code-tools` | python-skills: `python-hygiene-functional-style` |
| coding-agent-kanban-turns | `claude-code-tools` | `coding-agent-kanban-turn-responses`; software-design-skills: `design-hygiene-find-implicit-models` |
| jellyfin-settings | `applications` | python-skills: `python-hygiene-functional-style` |
| temptask | `applications` | nix-skills: `nix-clojure`, `nix-java`; xtdb-skills pack `agent-skills-nhooey-xtdb-all`; self-vendored malli, shadow-cljs, chaploud clojure-skills, re-frame-pair; its own `entity-kinds`, `uix` |
| chrome-extension-open-link-in-same-tab-popup-as-tab, chrome-extension-tab-scissors, pa-uimod-smallpause, pa-uimod-superselect (4) | `browser-extensions-and-game-mods` | none |
| github-config | `configuration` | coding-agent-skills: `kanban-turn-responses`, `questions-as-first-class-prompts`, `route-feedback-to-skills-over-memory`, `skill-references`; git-skills: `github-hygiene-single-commit-pull-requests`; python-skills: `python-hygiene-functional-style` |
| mynixos-private | `configuration` | mynixos-legacy-skills, whole |
| chrome-extension-declarative-tab-groups | none | git-skills whole; shell-skills whole; coding-agent-skills: `headless-in-checkout`, `plans-as-graph`, `scratchpad-scripts` |
| nix-devshell-cached-exports | none | as above, plus nix-skills: `nix-flakes` |
| nix-worktrees | none | `github:nhooey/skills-git` whole; `github:nhooey/skills-nix`: `nix-flakes` (old repository names) |
| claude-in-nix-devshell (`origin/main`, last commit 2026-10-19) | none | git-skills whole; nix-skills: `nix-flakes` |
| dendrometer | none (uses `sources/aggregated`) | 40 hand-listed first-party skills, nearly `base` plus input bumping, `kanban-turn-responses`, `browser-selection`, `skill-references`; gstack: 5 plan-review skills; superpowers: 11; trailofbits: 6; tla-check; pstack: 2 |

## Findings

- **`content` has no user.** It and `browser-extensions-and-game-mods` are both exactly `base`.
- **`python-hygiene-functional-style` is the most repeated extra:** 6 repositories in 4 families each add a `python-skills` flake input for it. Inside `skill-collections` it reaches 24 repositories, of which 7 collections track any `.py` file (coding-agent-skills 26, git-skills 10, nix-microsoft-skills 6, document-skills 5, mynixos-legacy-skills 3, legal-skills 2, shell-skills 2). The packaging repositories were not counted.
- **Superpowers:** all 14 reach 24 skill repositories; the only repository that chose superpowers by hand, dendrometer, took 11 and left out `writing-skills`, `using-superpowers`, `dispatching-parallel-agents`.
- **github-config re-lists 2 skills base already has** (`questions-as-first-class-prompts`, `route-feedback-to-skills-over-memory`).
- **5 repositories predate the families** and hand-list what is close to `base` plus the GitHub policies.
- **Locks:** consumers pin skillspkgs at `a72c483` (25 repositories), `ef90acb` (3), `066eecb` (6) or `bd1b085` (8).
- **To verify:** coding-agent-kanban-turns uses `inputs.coding-agent-skills` as a source but no matching input URL was seen in its flake.

## Corrections to the brief's premises

- **Shared sets are not re-listed skill by skill.** `families.nix` already defines `inputBumping`, `shippedDefaults` and `changelogs` once each, as `let` bindings. The real gap is that they are private: only the 9 families are exported, so a repository with extras, or one outside a family, cannot take a shared set and re-lists skills or adds its own flake input instead.
- **`skill-collections` holds 60 skills by count, not about 53:** base 42 + `coding-agent-skill-references` + `python-hygiene-functional-style` + humanizer + skill-creator + 14 superpowers.
- **skillspkgs has no `agents/plans/` or `agents/reports/` at `origin/master`**, so the plan creates both. "The cross-repository plan" that `families.nix` cites lives in github-config (`agents/plans/cross-repository-cleanup/`).
- **`authoring` and `authoring-with-git` have no consumers** in any `.nix` file at any surveyed `origin/master`.
