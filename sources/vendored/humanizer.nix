# Vendored skill: humanizer (blader/humanizer). Build logic lives canonically
# under ../../pkgs/humanizer/build.nix (also consumed standalone via `?dir=`);
# this file assembles it into the vendored category's per-item contract.
{
  nixpkgs,
  flake-skills,
  forSystems,
  humanizer-src,
  ...
}:
let
  humanizerFor =
    system:
    (import ../../pkgs/humanizer/build.nix {
      inherit nixpkgs flake-skills;
      src = humanizer-src;
    }).packages.${system}.default;
in
{
  vendoredSkillsFor = system: {
    agent-skill-humanizer = humanizerFor system;
  };

  sources.humanizer = {
    packages = forSystems (system: {
      agent-skill-humanizer = humanizerFor system;
    });
  };
}
