# Constructor consumed by user repos. Returns the per-system outputs
# (packages, apps.install, checks.skills-valid) plus the non-systemed
# homeManagerModules.default. Callers pass their own flake `inputs` so the
# closure has access to nixpkgs and `self` (needed by the home-manager
# module to point at the right per-system bundle).
{ flake-utils, mkSkill, discoverSkills }:
{ inputs
, src
, skillsSubdir ? "skills"
, systems ? flake-utils.lib.defaultSystems
}:
let
  perSystem = flake-utils.lib.eachSystem systems (system:
    let
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      skillsSrc = src + "/${skillsSubdir}";
      skills = discoverSkills { inherit pkgs; src = skillsSrc; };
      bundle = pkgs.symlinkJoin {
        name = "skills-bundle";
        paths = builtins.attrValues skills;
      };
      validator = pkgs.python3.withPackages (ps: [ ps.pyyaml ]);
      installApp = pkgs.writeShellApplication {
        name = "install-skills";
        runtimeInputs = [ pkgs.coreutils ];
        text = ''
          target="''${1:-$HOME/.claude/skills}"
          mkdir -p "$target"
          cp -rL --no-preserve=mode,ownership \
            ${bundle}/share/claude-skills/. "$target/"
          chmod -R u+w "$target"
        '';
      };
    in
    {
      packages = skills // { default = bundle; };
      apps.install = {
        type = "app";
        program = pkgs.lib.getExe installApp;
      };
      checks.skills-valid = pkgs.runCommand "skills-valid" {
        nativeBuildInputs = [ validator ];
      } ''
        python3 ${../checks/validate-skill-md.py} ${skillsSrc}
        touch $out
      '';
    });
in
perSystem // {
  homeManagerModules.default =
    import ./home-manager-module.nix { self = inputs.self; };
}
