# Canonical humanizer build. Imported by ./flake.nix (standalone `?dir=`
# consumption) and by the root flake's sources/vendored.nix, so the builder
# invocation lives in exactly one place — no duplication, no `path:` input.
{
  nixpkgs,
  flake-skills,
  src,
}:
flake-skills.lib.mkSkillFlake {
  inherit nixpkgs;
  skillName = "humanizer";
  packageName = "agent-skill-humanizer";
  inherit src;
}
