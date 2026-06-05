# Vendored module for blader/humanizer. The single-skill contract is shared via
# ../mk-simple-vendored.nix; see pkgs/default.nix for how the category fold
# consumes it and ./flake.nix for the standalone `?dir=pkgs/humanizer` face.
{
  nixpkgs,
  agent-skill-flake,
  src,
}:
import ../mk-simple-vendored.nix {
  inherit nixpkgs agent-skill-flake src;
  skillName = "humanizer";
  owner = "blader";
}
