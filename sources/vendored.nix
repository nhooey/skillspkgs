# CATEGORY 1 — vendored third-party skills (no upstream Nix flake).
#
# The per-source build logic + pack data live canonically under pkgs/<name>/
# (also consumed standalone via `github:nhooey/skillspkgs?dir=pkgs/<name>`);
# this module imports those build files and assembles them for the root flake.
# Imported as a plain Nix file — NOT a flake input — so it adds no `path:`
# input, keeping Garnix happy when skillspkgs is consumed transitively.
{
  nixpkgs,
  flake-skills,
  forSystems,
  humanizer-src,
  anthropics-skills-src,
  superpowers-src,
}:
let
  inherit (nixpkgs.lib) filterAttrs hasPrefix;

  humanizerFor =
    system:
    (import ../pkgs/humanizer/build.nix {
      inherit nixpkgs flake-skills;
      src = humanizer-src;
    }).packages.${system}.default;

  skillCreatorFor =
    system:
    (import ../pkgs/skill-creator/build.nix {
      inherit nixpkgs flake-skills;
      src = "${anthropics-skills-src}/skills/skill-creator";
    }).packages.${system}.default;

  superpowers = import ../pkgs/superpowers/build.nix {
    inherit nixpkgs flake-skills superpowers-src;
  };

  # superpowers' 14 individual skills (the `agent-skill-*` keys), dropping its
  # generic `default` / `agent-skills-all` aggregates — the latter would
  # collide with a category-2 key.
  superpowersSkillsFor =
    system: filterAttrs (n: _: hasPrefix "agent-skill-" n) superpowers.packages.${system};

  # superpowers' named packs (the `agent-skills-superpowers-*` envs).
  superpowersPacksFor =
    system: filterAttrs (n: _: hasPrefix "agent-skills-superpowers-" n) superpowers.packages.${system};
in
{
  # Every vendored package surfaced in packages.<sys>: the two single skills +
  # superpowers' 14 skills + superpowers' named packs.
  vendoredSkillsFor =
    system:
    {
      agent-skill-humanizer = humanizerFor system;
      agent-skill-skill-creator = skillCreatorFor system;
    }
    // superpowersSkillsFor system
    // superpowersPacksFor system;

  # Synthetic source flakes (`{ packages.<sys> = { ... }; }`) consumed by the
  # category-3 combinations via mkAggregateSkillsFlake, which reads a source
  # only through `source.packages.<system>`.
  sources = {
    humanizer = {
      packages = forSystems (system: {
        agent-skill-humanizer = humanizerFor system;
      });
    };
    skillCreator = {
      packages = forSystems (system: {
        agent-skill-skill-creator = skillCreatorFor system;
      });
    };
    superpowers = {
      packages = forSystems (system: superpowersSkillsFor system);
    };
  };
}
