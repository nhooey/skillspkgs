{
  description = "skillpkgs — library and curated collection of Agent Skills as Nix flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    let
      skillpkgsLib = import ./lib { inherit flake-utils; };
    in
    {
      lib = skillpkgsLib;

      homeManagerModules.default =
        import ./lib/home-manager-module.nix { inherit self; };

      templates.default = {
        path = ./templates/skills-repo;
        description = "A minimal flake that turns ./skills into a home-manager-installable bundle";
      };
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        wrappers = import ./pkgs {
          inherit pkgs;
          lib = pkgs.lib;
          mkSkill = skillpkgsLib.mkSkill;
        };
        bundle = pkgs.symlinkJoin {
          name = "skillpkgs-bundle";
          paths = builtins.attrValues wrappers;
        };
        validator = pkgs.python3.withPackages (ps: [ ps.pyyaml ]);
        installApp = pkgs.writeShellApplication {
          name = "skillpkgs-install";
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
        packages = wrappers // { default = bundle; };

        apps.install = {
          type = "app";
          program = pkgs.lib.getExe installApp;
        };

        checks.example = pkgs.runCommand "skillpkgs-example-check" {
          nativeBuildInputs = [ validator ];
        } ''
          python3 ${./checks/validate-skill-md.py} ${./examples/basic/skills}
          touch $out
        '';

        devShells.default = pkgs.mkShell {
          packages = [ pkgs.nixpkgs-fmt pkgs.python3 pkgs.jq ];
        };
      });
}
