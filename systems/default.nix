inputs:
let
  system = "x86_64-linux";
  my-homemanager-modules = builtins.attrValues inputs.my-modules.hmModules.${system};
  systemModules = [inputs.nixos-wsl.nixosModules.wsl]
   ++builtins.attrValues inputs.my-modules.nixosModules.${system}
   ++ [(inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")]
   ++ [ inputs.home-manager.nixosModules.home-manager];
   #++ 


  mkSystem = systemConf:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs my-homemanager-modules; };
      modules =  [ systemConf ] ++ systemModules ;
    };
in
{
  desktop = mkSystem (import ./desktop/mar.nix);
  #laptop= mkSystem (import ./desktop/mar.nix);
  wsl = mkSystem (import ./wsl.nix);
  #pi= mkSystem (import ./wsl.nix);
}
