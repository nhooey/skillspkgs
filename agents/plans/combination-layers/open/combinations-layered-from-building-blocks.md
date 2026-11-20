---
title: Combinations are layered from shared building blocks
state: proposed
kind: end-state
---

# Combinations are layered from shared building blocks

Based on the [survey of the skills dev shells' combinations](../../../reports/2026-11-20-skills-devshell-survey.md).

## Postconditions

- Every shared set of skills is one exported combination.
- Each family is `base` plus building blocks plus its own extras.
- No building block holds a `base` skill, so a family plus a block never lists a skill twice.
- `skill-collections` holds only `base` and `skill-authoring`.
- A repository takes a shared set from the `skillspkgs-combinations` input alone.

## Building blocks

Each is an exported `combinations.<name>`, holds no `base` skills, and is spliced into families as a source. A consumer takes its family plus any block from the one `skillspkgs-combinations` input. A set earns a block when 2 or more families, or 3 or more repositories, take it.

| Block | Skills | Used by |
| --- | --- | --- |
| `base` (unchanged) | the 42 today | every family |
| `skill-authoring` | `coding-agent-skill-references`, humanizer, `anthropic-skill-creator`, `superpowers-writing-skills`; possibly `skill-authoring-write-for-a-capable-model` (needs a new input) | `skill-collections`, `skill-packaging` |
| `input-bumping` | `nix-flake-recursive-bump-input-versions` | `skill-packaging`, `nix-tooling`, `configuration`; dendrometer |
| `releases` | `config-hygiene-shipped-defaults`, `update-changelog` | `nix-tooling`, `claude-code-tools`, `applications` |
| `github-policy` | the 4 `github-policy-*` skills | `configuration`; the 4 hand-written repositories that take git-skills whole |
| `python` | `python-hygiene-functional-style` | the 6 repositories that add it today, plus the 7 collections with Python |
| `development-workflow` | superpowers, prefixed: `brainstorming`, `writing-plans`, `executing-plans`, `subagent-driven-development`, `dispatching-parallel-agents`, `test-driven-development`, `systematic-debugging`, `requesting-code-review`, `receiving-code-review`, `verification-before-completion`, `finishing-a-development-branch`, `using-git-worktrees` (12) | dendrometer; no family by default |
| `nix-clojure` (candidate) | `nix-clojure` | nix-cljfmt, nix-github-actions-cache-bench, temptask |

## Families

| Family | Is | Change in content |
| --- | --- | --- |
| `skill-collections` | `base` + `skill-authoring` | 60 to 46 skills |
| `skill-packaging` | `skill-collections` + `input-bumping` | 61 to 47 |
| `nix-tooling` | `base` + `input-bumping` + `releases` | none |
| `claude-code-tools` | `base` + `releases` + `typescript-strict` | none |
| `applications` | `base` + `releases` | none |
| `configuration` | `base` + `input-bumping` + `github-policy` | none |
| `browser-extensions-and-game-mods`, `content` | `base` | none |

## What leaves `skill-collections`

- `python-hygiene-functional-style` goes to the `python` block; the 7 collections with Python add it.
- 12 superpowers skills go to `development-workflow`.
- `superpowers-using-superpowers` goes to no combination.
- `superpowers-writing-skills` stays, through `skill-authoring`.

## Skills that stay single sources

- **Taken by 1 or 2 repositories:** `coding-agent-browser-selection`, `design-hygiene-find-implicit-models`, `github-hygiene-single-commit-pull-requests`, `nix-java`, `superpowers-using-superpowers`, `typescript-strict` (stays a `claude-code-tools` extra).
- **Taken by 3 but in no shared set:** `coding-agent-kanban-turn-responses` (github-config, coding-agent-kanban-turns, dendrometer).
- **Domain packs:** mynixos-legacy-skills, xtdb-skills, temptask's vendored Clojure skills and its own two, dendrometer's trailofbits, tla-check, pstack and gstack picks.
- **In no dev shell today:** `git-workflow-tidy-worktrees`, `nix-language-packaging`, the other 5 coding-agent skills, the other 4 software-design skills, 3 writing skills, data-skills, macos-skills, agent-output-skills.

## Open questions

1. **Python in collections:** remove `python-hygiene-functional-style` from `skill-collections` and have the 7 Python-bearing collections add the `python` block (7 flake edits), or keep it in the family?
2. **Superpowers:** should any family include `development-workflow` (for example `applications`), or is it opt-in only? Is dropping `using-superpowers` from every dev shell right?
3. **One-skill blocks:** are `python`, `input-bumping` and `nix-clojure` worth exporting as combinations? Their gain is one fewer flake input and lock entry per consumer.
4. **`skill-authoring-write-for-a-capable-model`:** add `skill-authoring-skills` as a combinations input so `skill-authoring` holds it?
5. **`authoring` and `authoring-with-git`:** remove them, given no consumers?
6. **`content` and `browser-extensions-and-game-mods`:** keep as names equal to `base`, or drop `content`, which no repository uses?
7. **`writing-hygiene-declarative-statements`:** add to `base`? `coding-agent-plans-as-graph`, which is in base, names it as a related skill.
8. **The 5 hand-written dev shells:** migrate them (Wave C)? nix-worktrees still points at `skills-git` and `skills-nix`; claude-in-nix-devshell has been idle since 2026-10-19.
9. **`coding-agent-kanban-turn-responses`:** 3 repositories take it. Leave single, or put it in `base`?
