{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    skillpkgs.url = "github:nhooey/skillspkgs";
  };
  outputs = inputs: inputs.skillpkgs.lib.mkSkillsFlake {
    inherit inputs;
    src = ./.;
  };
}
