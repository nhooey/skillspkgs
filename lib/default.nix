# Top-level entry point for the skillpkgs library. The lib is non-systemed:
# functions take `pkgs` (or `inputs`) at call time so a single import works
# across systems. See ./mk-skill.nix, ./discover.nix, ./mk-skills-flake.nix.
{ flake-utils }:
rec {
  mkSkill = import ./mk-skill.nix;
  discoverSkills = import ./discover.nix { inherit mkSkill; };
  mkSkillsFlake = import ./mk-skills-flake.nix {
    inherit flake-utils mkSkill discoverSkills;
  };
}
