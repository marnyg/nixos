#{ nixpkgs, my-modules, home-manager, nur }:
inputs:
let
  system = "x86_64-linux";
  my-modules = builtins.attrValues inputs.my-modules.nixosModules.${system};
  buildIsoModule = (inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix");
  homemanager-module = inputs.home-manager.nixosModules.home-manager;
  nur-module = inputs.nur.nixosModules.nur;
  wsl-module = inputs.nixos-wsl.nixosModules.wsl;

  systemModules = [ buildIsoModule homemanager-module nur-module wsl-module ] ++ my-modules;
  my-homemanager-modules = builtins.attrValues inputs.my-modules.hmModules.${system};

  mkSystem = systemConf:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs homemanager-module my-homemanager-modules; };
      modules = systemModules ++ [ systemConf ];
    };
in
{
  desktop = mkSystem (import ./desktop/mar.nix);
  #laptop= mkSystem (import ./desktop/mar.nix);
  wsl = mkSystem (import ./wsl.nix);
  #pi= mkSystem (import ./wsl.nix);
}
