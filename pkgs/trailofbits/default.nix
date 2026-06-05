# Canonical trailofbits module: every skill in trailofbits/skills built via
# mkAllSkillsFlake, with the vendored-category contract. Imported by ./flake.nix
# (standalone `?dir=pkgs/trailofbits` use) and by ../default.nix (the root's
# plain `import` fold).
#
# Like superpowers/daymade (and unlike humanizer/skill-creator) this contributes
# MANY packages: 74 individual `agent-skill-trailofbits-*` skills. No curated
# topical packs — just the per-skill drvs plus the base
# `agent-skills-trailofbits-all` aggregate on the standalone face.
#
# Two upstream-layout facts shape the build:
#   • trailofbits/skills is a plugin-marketplace monorepo: skills live three
#     levels down at `plugins/<plugin>/skills/<skill>/SKILL.md`, not under a flat
#     top-level `skills/`. mkAllSkillsFlake's discoverSkills recurses through
#     grouping dirs (a dir with SKILL.md is a leaf), so one call rooted at
#     `${src}/plugins` finds all 74; the per-plugin `skills/` nesting needs no
#     per-suite loop. Each skill's `name` is its own directory basename, so the
#     plugin grouping never leaks into skill identity.
#   • Many skills keep referenced material in non-whitelist subdirs (`resources/`
#     rather than the standard `references/`, plus `workflows/`, `templates/`,
#     `examples/`, ...) and loose top-level companion `.md` files
#     (methodology.md, patterns.md, ...). mkAllSkillsFlake ships only SKILL.md +
#     references/ + scripts/ by default, so `extraDirs` / `extraFiles` re-add
#     that content.
#
# `source = { owner = "trailofbits"; }` namespaces every package key as
# `agent-skill-trailofbits-<name>`, keeping these from colliding with other
# vendored owners in the root package set. The installed skill name stays bare.
{
  nixpkgs,
  agent-skill-flake,
  src,
}:
let
  inherit (nixpkgs.lib) filterAttrs hasPrefix mapAttrs;

  base = agent-skill-flake.lib.mkAllSkillsFlake {
    inherit nixpkgs;
    source = {
      owner = "trailofbits";
    };
    skillsDir = "${src}/plugins";
    packagePrefix = "agent-skill-";
    # Non-standard content dirs several skills reference (their primary material
    # often lives in `resources/`, not the whitelisted `references/`).
    extraDirs = [
      "resources"
      "workflows"
      "templates"
      "examples"
      "reference"
      "configs"
      "prompts"
      "schemas"
      "tools"
      "cards"
      "houses"
    ];
    # Loose top-level companion files some SKILL.md files cross-reference
    # (methodology.md, patterns.md, ...). `*.md` also re-matches SKILL.md, which
    # the build overwrites with its frontmatter-normalized copy.
    extraFiles = [ "*.md" ];
  };

  # Root + combinations views: the individual skills only. `hasPrefix
  # "agent-skill-"` keeps the singular per-skill keys and drops both `default`
  # and the plural `agent-skills-trailofbits-all` aggregate.
  skillsOnly = mapAttrs (_: filterAttrs (n: _: hasPrefix "agent-skill-" n)) base.packages;
in
base
// {
  vendoredSkills = skillsOnly;
  source.packages = skillsOnly;
}
