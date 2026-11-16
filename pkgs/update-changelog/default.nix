# Vendored module for mitsuhiko/agent-stuff's update-changelog skill (the skills/update-changelog subdir).
# The single-skill contract is shared via ../mk-simple-vendored.nix; see
# pkgs/default.nix for how the category fold consumes it and ./flake.nix for
# the standalone `?dir=pkgs/update-changelog` face.
{
  nixpkgs,
  agent-skill-flake,
  src,
}:
import ../mk-simple-vendored.nix {
  inherit nixpkgs agent-skill-flake src;
  skillName = "update-changelog";
  owner = "mitsuhiko";
  srcSubpath = "skills/update-changelog";
}
