{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    skillpkgs.url = "path:../..";
  };
  outputs = inputs: inputs.skillpkgs.lib.mkSkillsFlake {
    inherit inputs;
    src = ./.;
  };
}
