# Re-export of the home-manager module. The closure over `self` is bound
# inside flake.nix; this file exists so consumers who prefer module-style
# discovery (`modules/<name>.nix`) can find it where they expect.
import ../lib/home-manager-module.nix
