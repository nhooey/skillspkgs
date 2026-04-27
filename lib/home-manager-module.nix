# home-manager module that symlinks a list of skill packages into
# ~/.claude/skills/. Each skill package is expected to expose
# share/claude-skills/<name>/ (the layout produced by
# flake-skills.lib.mkSkillFlake).
{ config, lib, pkgs, ... }:
let
  cfg = config.programs.agent-skills;
in
{
  options.programs.agent-skills = {
    enable = lib.mkEnableOption "Symlink Agent Skills bundle entries into the target directory";

    target = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.claude/skills";
      description = "Directory to install skills into (one symlink per skill).";
    };

    skills = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      example = lib.literalExpression ''
        [
          inputs.humanizer.packages.''${pkgs.system}.default
        ]
      '';
      description = ''
        Skill derivations to install. Each derivation is expected to expose
        share/claude-skills/<name>/ — the layout produced by
        flake-skills.lib.mkSkillFlake.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.activation.installAgentSkills =
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        target=${lib.escapeShellArg cfg.target}
        run mkdir -p "$target"
        ${lib.concatMapStringsSep "\n" (skill: ''
          for skill_dir in ${skill}/share/claude-skills/*; do
            [ -d "$skill_dir" ] || continue
            name=$(basename "$skill_dir")
            run ln -sfn "$skill_dir" "$target/$name"
          done
        '') cfg.skills}
      '';
  };
}
