# Build a single Agent Skill into $out/share/claude-skills/<name>/.
#
# - Strips any skill.nix sidecar from the install tree (it's metadata for
#   discovery, not content shipped to Claude).
# - Wraps executable scripts in scripts/ with runtimeInputs on PATH so a
#   skill's helper tools can find their dependencies at run time.
{ pkgs, name, src, runtimeInputs ? [ ] }:
let
  binPath = pkgs.lib.makeBinPath runtimeInputs;
in
pkgs.stdenv.mkDerivation {
  pname = name;
  version = "0";
  inherit src;
  nativeBuildInputs = [ pkgs.makeWrapper ];
  dontBuild = true;
  installPhase = ''
    runHook preInstall
    target="$out/share/claude-skills/${name}"
    mkdir -p "$(dirname "$target")"
    cp -r --no-preserve=mode . "$target"
    chmod -R u+w "$target"
    rm -f "$target/skill.nix"
  '' + pkgs.lib.optionalString (runtimeInputs != [ ]) ''
    if [ -d "$target/scripts" ]; then
      for script in "$target"/scripts/*; do
        [ -f "$script" ] || continue
        chmod +x "$script"
        wrapped="''${script}.real"
        mv "$script" "$wrapped"
        makeWrapper "$wrapped" "$script" --prefix PATH : ${binPath}
      done
    fi
  '' + ''
    runHook postInstall
  '';
}
