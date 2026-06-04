# Vendored module for Anthropic's skill-creator (the skills/skill-creator subdir
# of anthropics/skills). The single-skill contract is shared via
# ../mk-simple-vendored.nix; the subpath slice is passed as `srcSubpath` so this
# and the standalone `?dir=pkgs/skill-creator` face both pass the raw
# anthropics-skills-src.
{
  nixpkgs,
  flake-skills,
  src,
}:
import ../mk-simple-vendored.nix {
  inherit nixpkgs flake-skills src;
  skillName = "skill-creator";
  owner = "anthropics";
  srcSubpath = "skills/skill-creator";
}
