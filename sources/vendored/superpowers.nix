# Vendored skill set: superpowers (obra/superpowers). Build logic + pack data
# live canonically under ../../pkgs/superpowers/{build,packs}.nix (also consumed
# standalone via `?dir=`); this file assembles it into the per-item contract.
#
# Unlike humanizer/skill-creator, this contributes MANY packages: superpowers'
# 14 individual `agent-skill-*` skills plus its named `agent-skills-superpowers-*`
# pack envs. Its generic `default` / `agent-skills-all` aggregates are dropped —
# the latter would collide with a category-2 key. The synthetic source exposes
# only the skills (packs excluded), matching what the combinations consume.
{
  nixpkgs,
  flake-skills,
  forSystems,
  superpowers-src,
  ...
}:
let
  inherit (nixpkgs.lib) filterAttrs hasPrefix;

  superpowers = import ../../pkgs/superpowers/build.nix {
    inherit nixpkgs flake-skills superpowers-src;
  };

  superpowersSkillsFor =
    system: filterAttrs (n: _: hasPrefix "agent-skill-" n) superpowers.packages.${system};

  superpowersPacksFor =
    system: filterAttrs (n: _: hasPrefix "agent-skills-superpowers-" n) superpowers.packages.${system};
in
{
  vendoredSkillsFor = system: superpowersSkillsFor system // superpowersPacksFor system;

  sources.superpowers = {
    packages = forSystems (system: superpowersSkillsFor system);
  };
}
