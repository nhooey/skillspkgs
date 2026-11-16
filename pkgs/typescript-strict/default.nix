# Vendored module for citypaul/.dotfiles's typescript-strict skill (the claude/.claude/skills/typescript-strict subdir).
# The single-skill contract is shared via ../mk-simple-vendored.nix; see
# pkgs/default.nix for how the category fold consumes it and ./flake.nix for
# the standalone `?dir=pkgs/typescript-strict` face.
{
  nixpkgs,
  agent-skill-flake,
  src,
}:
import ../mk-simple-vendored.nix {
  inherit nixpkgs agent-skill-flake src;
  skillName = "typescript-strict";
  owner = "citypaul";
  srcSubpath = "claude/.claude/skills/typescript-strict";
}
