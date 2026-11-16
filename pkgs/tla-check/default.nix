# Vendored module for younes-io/agent-skills's tla-check skill (the
# plugins/tla-workbenches/skills/tla-check subdir), shipped unchanged with the
# repo-root MIT LICENSE beside it. The build leaves out the Codex-only
# agents/openai.yaml, and the sibling tla-proof skill is not packaged. Its
# scripts need `java`, `jq` and a `tla2tools.jar` named by `TLA2TOOLS_JAR` at
# run time, which the consuming project's dev shell provides. The single-skill
# contract is shared via ../mk-simple-vendored.nix; see pkgs/default.nix for
# how the category fold consumes it and ./flake.nix for the standalone
# `?dir=pkgs/tla-check` face.
{
  nixpkgs,
  agent-skill-flake,
  src,
}:
import ../mk-simple-vendored.nix {
  inherit nixpkgs agent-skill-flake src;
  skillName = "tla-check";
  owner = "younes-io";
  srcSubpath = "plugins/tla-workbenches/skills/tla-check";
  licenseFile = "LICENSE";
}
