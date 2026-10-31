# Vendored module for stoating/clojure-shadow-cljs-skill (MIT): the shadow-cljs
# ClojureScript build tool. SKILL.md routes to sibling reference .md files, which
# are shipped by name; the LICENSE sits at the repo root, outside the skill
# directory. The single-skill contract is shared via ../mk-simple-vendored.nix.
{
  nixpkgs,
  agent-skill-flake,
  src,
}:
import ../mk-simple-vendored.nix {
  inherit nixpkgs agent-skill-flake src;
  skillName = "shadow-cljs";
  owner = "stoating";
  srcSubpath = "skills/shadow-cljs";
  extraFiles = [
    "commands.md"
    "configuration.md"
    "interop.md"
    "targets.md"
    "troubleshooting.md"
    "workflows.md"
  ];
}
