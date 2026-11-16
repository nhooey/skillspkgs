# Runs the home-manager module's activation script against two fake skill
# packages and checks the symlinks it leaves behind. home-manager itself is
# stubbed: `home.homeDirectory`, `home.activation` and `lib.hm.dag.entryAfter`
# are the only parts of it the module touches.
{ pkgs }:
let
  inherit (pkgs) lib;

  hmLib = lib.extend (
    _: _: {
      hm.dag.entryAfter = after: data: { inherit after data; };
    }
  );

  homeStub =
    { lib, ... }:
    {
      options.home = {
        homeDirectory = lib.mkOption { type = lib.types.str; };
        activation = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = { };
        };
      };
    };

  evalWith =
    config:
    (lib.evalModules {
      specialArgs = {
        inherit pkgs;
        lib = hmLib;
      };
      modules = [
        homeStub
        ../lib/home-manager-module.nix
        { home.homeDirectory = "/home/tester"; }
        config
      ];
    }).config;

  # Two skills plus a stray file, which the module must skip.
  skillsAB = pkgs.runCommand "fake-skills-ab" { } ''
    mkdir -p $out/share/claude-skills/alpha $out/share/claude-skills/beta
    echo alpha > $out/share/claude-skills/alpha/SKILL.md
    echo beta > $out/share/claude-skills/beta/SKILL.md
    echo stray > $out/share/claude-skills/README
  '';
  skillsC = pkgs.runCommand "fake-skills-c" { } ''
    mkdir -p $out/share/claude-skills/gamma
    echo gamma > $out/share/claude-skills/gamma/SKILL.md
  '';

  enabled = evalWith {
    programs.agent-skills = {
      enable = true;
      # A space in the path proves the target is quoted.
      target = "@TARGET@/agent skills";
      skills = [
        skillsAB
        skillsC
      ];
    };
  };
  disabled = evalWith { programs.agent-skills.skills = [ skillsAB ]; };
  defaulted = evalWith { programs.agent-skills.enable = true; };

  activation = enabled.home.activation.installAgentSkills;
  script = pkgs.writeText "install-agent-skills" activation.data;

  expect =
    cond: msg: lib.optionalString (!cond) "echo ${lib.escapeShellArg "FAIL: ${msg}"} >&2; exit 1";
in
pkgs.runCommand "home-manager-module-test" { } ''
  set -euo pipefail
  ${expect (activation.after == [ "writeBoundary" ]) "activation must run after writeBoundary"}
  ${expect (
    !(disabled.home.activation ? installAgentSkills)
  ) "a disabled module must add no activation"}
  ${expect (
    defaulted.programs.agent-skills.target == "/home/tester/.claude/skills"
  ) "the target must default to ~/.claude/skills"}

  root=$TMPDIR/home
  dest="$root/agent skills"
  # A stale link to a directory, from an earlier generation, must be
  # replaced rather than followed and written into.
  mkdir -p "$dest" "$root/old-alpha"
  ln -s "$root/old-alpha" "$dest/alpha"

  run() { "$@"; }
  source <(sed "s|@TARGET@|$root|g" ${script})

  fail() { echo "FAIL: $*" >&2; exit 1; }
  for pair in alpha:${skillsAB} beta:${skillsAB} gamma:${skillsC}; do
    name=''${pair%%:*} pkg=''${pair#*:}
    [ -L "$dest/$name" ] || fail "$name is not a symlink"
    [ "$(readlink "$dest/$name")" = "$pkg/share/claude-skills/$name" ] ||
      fail "$name points at $(readlink "$dest/$name")"
    [ "$(cat "$dest/$name/SKILL.md")" = "$name" ] || fail "$name/SKILL.md is not reachable"
  done
  [ ! -e "$dest/README" ] || fail "a file in share/claude-skills was linked"
  [ "$(ls -A "$dest" | wc -l)" -eq 3 ] || fail "expected 3 entries, got: $(ls -A "$dest")"
  [ -z "$(ls -A "$root/old-alpha")" ] || fail "a link was written through the stale alpha link"

  touch $out
''
