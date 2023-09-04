inputs:
let
  system = "x86_64-linux";
  myModules = (builtins.attrValues inputs.my-modules.nixosModules.x86_64-linux);
  homeManagerModule = inputs.home-manager.nixosModules.home-manager;
  wslModule = inputs.nixos-wsl.nixosModules.wsl;

  additionalModules = myModules ++ [ homeManagerModule wslModule ];
in
{
  #desktop = mkSystem (import ./desktop/mar.nix);
  #laptop= mkSystem (import ./laptop/default.nix);

  laptop = inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs; };
    modules = [ (import ./laptop/default.nix) ] ++ additionalModules;
  };

  #mkSystem (import ./laptop/default.nix);
  #wsl = mkSystem (import ./wsl.nix);
  #la = myModules;

  wsl = inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs; };
    modules = [ (import ./wslRefac.nix) ] ++ additionalModules;
  };
  #wsl2 = inputs.nixpkgs.lib.nixosSystem {
  #  inherit system;
  #  specialArgs = { inherit inputs; };
  #  modules = [ (import ./wsl.nix) ];
  #};

  #pi= mkSystem (import ./wsl.nix);
}
