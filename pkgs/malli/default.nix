# Vendored module for stoating/clojure-malli-skill (MIT): Malli data schemas for
# Clojure. SKILL.md routes to sibling reference .md files, which are shipped by
# name; the LICENSE sits at the repo root, outside the skill directory. The
# single-skill contract is shared via ../mk-simple-vendored.nix.
{
  nixpkgs,
  agent-skill-flake,
  src,
}:
import ../mk-simple-vendored.nix {
  inherit nixpkgs agent-skill-flake src;
  skillName = "malli";
  owner = "stoating";
  srcSubpath = "skills/malli";
  extraFiles = [
    "anti-patterns.md"
    "function-schemas.md"
    "generation-inference.md"
    "registries.md"
    "schema-tools.md"
    "schemas.md"
    "transform-coerce.md"
    "validation-errors.md"
  ];
}
