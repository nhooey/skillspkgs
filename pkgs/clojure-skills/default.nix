# Vendored module for chaploud/clojure-skills (EPL-2.0): structural search and
# editing of S-expressions, nREPL evaluation and clojure-lsp navigation. SKILL.md
# and references/ sit at the repo root; the repo's own src/ is the `clj-skill`
# Babashka CLI the skill calls, which consumers package separately. LICENSE is
# shipped beside SKILL.md. The single-skill contract is shared via
# ../mk-simple-vendored.nix.
{
  nixpkgs,
  agent-skill-flake,
  src,
}:
import ../mk-simple-vendored.nix {
  inherit nixpkgs agent-skill-flake src;
  skillName = "clojure-skills";
  owner = "chaploud";
  extraFiles = [ "LICENSE" ];
}
