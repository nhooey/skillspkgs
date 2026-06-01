# Canonical superpowers build: every skill under obra/superpowers built via
# mkAllSkillsFlake, plus the named pack envs from ./packs.nix. Imported by
# ./flake.nix (standalone `?dir=` consumption) and by the root flake's
# sources/vendored.nix.
#
# NOTE — upstream layout caveat.
# `flake-skills.lib.mkAllSkillsFlake` ships only SKILL.md, references/, and
# scripts/ per skill (Anthropic's official agent-skill spec). Several
# obra/superpowers skills carry loose top-level companion files outside that
# whitelist — e.g. systematic-debugging's condition-based-waiting.md /
# root-cause-tracing.md, test-driven-development's testing-anti-patterns.md,
# writing-skills' anthropic-best-practices.md + persuasion-principles.md. The
# core SKILL.md prose still works; the dropped files are referenced for deeper
# context. To ship them, extend flake-skills with an `extraFiles` knob
# (analogous to `extraDirs`) and bump the rev.
{
  nixpkgs,
  flake-skills,
  superpowers-src,
}:
let
  base = flake-skills.lib.mkAllSkillsFlake {
    inherit nixpkgs;
    skillsDir = "${superpowers-src}/skills";
    packagePrefix = "agent-skill-";
  };

  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "x86_64-darwin"
    "aarch64-darwin"
  ];
  forSystems = nixpkgs.lib.genAttrs systems;

  packs = import ./packs.nix;

  mkEnv =
    system: packName: skillNames:
    flake-skills.lib.mkSkillsEnv {
      pkgs = nixpkgs.legacyPackages.${system};
      name = packName;
      skills = builtins.map (n: base.packages.${system}."agent-skill-${n}") skillNames;
    };

  packPackages = forSystems (
    system: nixpkgs.lib.mapAttrs (packName: skillNames: mkEnv system packName skillNames) packs
  );
in
base
// {
  packages = nixpkgs.lib.recursiveUpdate base.packages packPackages;
}
