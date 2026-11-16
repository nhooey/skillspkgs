# Vendored module for two skills from cursor/plugins's pstack suite (the
# pstack/skills subdir, MIT): create-formal-verification-skill and
# maintain-formal-verification-skill, each with pstack's LICENSE beside it.
# Both keep `disable-model-invocation: true`. Each is built through
# ../mk-simple-vendored.nix with the patch beside it, whose header names the
# upstream commit and lists the edits: no pointer to pstack's statechart skill
# (it installs Java and downloads TLC at run time), bare skill names, tools
# from the project's Nix dev shell, and a Related skills section. The other
# pstack skills are not packaged. See pkgs/default.nix for how the category
# fold consumes this and ./flake.nix for the standalone `?dir=pkgs/pstack` face.
{
  nixpkgs,
  agent-skill-flake,
  src,
}:
let
  inherit (nixpkgs.lib) foldl' recursiveUpdate;

  skill =
    skillName:
    import ../mk-simple-vendored.nix {
      inherit
        nixpkgs
        agent-skill-flake
        src
        skillName
        ;
      owner = "cursor";
      srcSubpath = "pstack/skills/${skillName}";
      patches = [ ./${skillName}.patch ];
      licenseFile = "pstack/LICENSE";
    };

  skills = map skill [
    "create-formal-verification-skill"
    "maintain-formal-verification-skill"
  ];

  merge = view: foldl' (acc: s: recursiveUpdate acc (view s)) { } skills;
in
{
  # Per-skill keys only: each skill's `default` alias would shadow the other's.
  packages = merge (s: s.vendoredSkills);
  vendoredSkills = merge (s: s.vendoredSkills);
  source.packages = merge (s: s.source.packages);
}
