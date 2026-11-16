# Vendored module for apollographql/skills's rust-best-practices skill (the skills/rust-best-practices subdir).
# The single-skill contract is shared via ../mk-simple-vendored.nix; see
# pkgs/default.nix for how the category fold consumes it and ./flake.nix for
# the standalone `?dir=pkgs/rust-best-practices` face.
{
  nixpkgs,
  agent-skill-flake,
  src,
}:
import ../mk-simple-vendored.nix {
  inherit nixpkgs agent-skill-flake src;
  skillName = "rust-best-practices";
  owner = "apollographql";
  srcSubpath = "skills/rust-best-practices";
}
