# Vendored module for blader/humanizer. The single-skill contract is shared via
# ../mk-simple-vendored.nix; see pkgs/default.nix for how the category fold
# consumes it and ./flake.nix for the standalone `?dir=pkgs/humanizer` face.
{
  nixpkgs,
  flake-skills,
  src,
}:
import ../mk-simple-vendored.nix {
  inherit nixpkgs flake-skills src;
  skillName = "humanizer";
  owner = "blader";
}
