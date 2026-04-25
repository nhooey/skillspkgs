# Closure-pattern module: the parent flake passes its own `self` so the
# module can find the per-system skills bundle via
# `self.packages.${pkgs.system}.default`. Activation copies (not symlinks)
# because Claude Code reads skill files directly and does not follow
# symlinks across the skill boundary — symlinked installs surface as
# missing or unreadable skills.
{ self }:
{ config, lib, pkgs, ... }:
let
  cfg = config.programs.agent-skills;
in
{
  options.programs.agent-skills = {
    enable = lib.mkEnableOption "Install Agent Skills bundle into the target directory";

    target = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.claude/skills";
      description = "Directory to install skills into. Files are copied, not symlinked.";
    };

    forceClean = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Remove all files at `target` before copying. Off by default.";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = self.packages.${pkgs.system}.default;
      defaultText = lib.literalExpression "self.packages.\${pkgs.system}.default";
      description = "The bundled skills derivation to install.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.activation.installAgentSkills =
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        target=${lib.escapeShellArg cfg.target}
        ${lib.optionalString cfg.forceClean ''
          run rm -rf -- "$target"
        ''}
        run mkdir -p "$target"
        run cp -rL --no-preserve=mode,ownership \
          ${cfg.package}/share/claude-skills/. "$target/"
        run chmod -R u+w "$target"
      '';
  };
}
