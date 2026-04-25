# Walk a directory and build every subfolder that contains a SKILL.md.
# Optionally honors a per-skill `skill.nix` sidecar of the form
#   { pkgs, ... }: { runtimeInputs = [ ... ]; }
# whose attributes are forwarded to mkSkill.
{ mkSkill }:
{ pkgs, src }:
let
  lib = pkgs.lib;
  isSkillDir = name: type:
    type == "directory"
    && builtins.pathExists (src + "/${name}/SKILL.md");
  skillDirs = lib.filterAttrs isSkillDir (builtins.readDir src);
  buildSkill = name: _:
    let
      skillSrc = src + "/${name}";
      sidecar = skillSrc + "/skill.nix";
      meta =
        if builtins.pathExists sidecar
        then import sidecar { inherit pkgs; }
        else { };
    in
    mkSkill {
      inherit pkgs name;
      src = skillSrc;
      runtimeInputs = meta.runtimeInputs or [ ];
    };
in
lib.mapAttrs buildSkill skillDirs
