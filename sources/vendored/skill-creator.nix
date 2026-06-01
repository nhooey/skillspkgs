# Vendored skill: skill-creator (anthropics/skills · skills/skill-creator). Build
# logic lives canonically under ../../pkgs/skill-creator/build.nix (also consumed
# standalone via `?dir=`); this file assembles it into the per-item contract.
#
# The source key is `skillCreator` (camelCase), decoupled from this kebab-case
# filename — sources/combinations/authoring.nix references `sources.skillCreator`.
{
  nixpkgs,
  flake-skills,
  forSystems,
  anthropics-skills-src,
  ...
}:
let
  skillCreatorFor =
    system:
    (import ../../pkgs/skill-creator/build.nix {
      inherit nixpkgs flake-skills;
      src = "${anthropics-skills-src}/skills/skill-creator";
    }).packages.${system}.default;
in
{
  vendoredSkillsFor = system: {
    agent-skill-skill-creator = skillCreatorFor system;
  };

  sources.skillCreator = {
    packages = forSystems (system: {
      agent-skill-skill-creator = skillCreatorFor system;
    });
  };
}
