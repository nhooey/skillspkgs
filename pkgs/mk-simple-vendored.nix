# Shared builder for single-skill vendored modules whose only variation is the
# skill name, upstream owner, and an optional source subpath. humanizer and
# skill-creator both reduce to this; superpowers stays bespoke in its own
# default.nix (it builds many skills plus pack envs).
#
# `owner` is the upstream GitHub owner; agent-skill-flake's default `namespaceFn`
# keys the package as `agent-skill-<owner>-<skillName>` while the installed
# skill name stays the bare `skillName`.
#
# Returns the same contract as a hand-written pkgs/<name>/default.nix:
#   built // { vendoredSkills; source.packages; }
# where `built` is the mkSkillFlake output (full packages, incl. the `default`
# alias) for the standalone face, and the two added views drop everything but the
# `agent-skill-*` keys for the root package set and the combinations category.
#
# `patches` and `licenseFile` change the built skill derivations, so a wrapper
# that sets either keeps only `packages` from `built`: mkSkillFlake's apps would
# install the unpatched skill.
{
  nixpkgs,
  agent-skill-flake,
  src,
  skillName,
  owner,
  # Optional path under `src` to the skill. Upstreams that ship many skills in
  # one repo (e.g. anthropics/skills) need this; null uses `src` as-is.
  srcSubpath ? null,
  # Files and directories beside SKILL.md that the skill needs, beyond the
  # SKILL.md, references/ and scripts/ that mkSkillFlake always ships: e.g.
  # sibling reference .md files that SKILL.md routes to, or a LICENSE.
  extraDirs ? [ ],
  extraFiles ? [ ],
  # Patches applied to the skill directory before it is installed, `-p1`
  # relative to that directory (`a/SKILL.md`). Each patch file's header names
  # the upstream commit it applies to and lists its edits.
  patches ? [ ],
  # Path under `src` (not under `srcSubpath`) of the upstream licence, shipped
  # beside SKILL.md as LICENSE, for upstreams that keep it at the repo root.
  licenseFile ? null,
}:
let
  inherit (nixpkgs.lib)
    filterAttrs
    hasPrefix
    mapAttrs
    optionalString
    ;

  built = agent-skill-flake.lib.mkSkillFlake {
    inherit
      nixpkgs
      skillName
      extraDirs
      extraFiles
      ;
    source = { inherit owner; };
    src = if srcSubpath == null then src else "${src}/${srcSubpath}";
  };

  modified = patches != [ ] || licenseFile != null;

  modify =
    drv:
    drv.overrideAttrs (old: {
      inherit patches;
      postInstall =
        (old.postInstall or "")
        + optionalString (licenseFile != null) ''
          install -Dm644 ${src}/${licenseFile} \
            "$out/share/claude-skills/${drv.passthru.flakeSkillName}/LICENSE"
        '';
    });

  packages = if modified then mapAttrs (_: mapAttrs (_: modify)) built.packages else built.packages;

  skillsOnly = mapAttrs (_: filterAttrs (n: _: hasPrefix "agent-skill-" n)) packages;
in
(if modified then { inherit packages; } else built)
// {
  vendoredSkills = skillsOnly;
  source.packages = skillsOnly;
}
