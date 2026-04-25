# Curated wrappers for third-party Agent Skills.
#
# Each wrapper lives in its own folder under ./pkgs/ with a default.nix that
# vendors only metadata: an upstream URL, a revision, and a sha256. We never
# re-host upstream source. See ./README.md for the contributor checklist.
#
# `hello-example` below is a placeholder so the package set is non-empty
# during bootstrap — delete it once the first real wrapper lands.
{ pkgs, lib, mkSkill }:
{
  hello-example = mkSkill {
    inherit pkgs;
    name = "hello";
    src = ../examples/basic/skills/hello;
  };
}
