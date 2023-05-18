inputs:
let
  system = "x86_64-linux";
in
{
  #desktop = mkSystem (import ./desktop/mar.nix);
  #laptop= mkSystem (import ./desktop/mar.nix);
  #wsl = mkSystem (import ./wsl.nix);
  wsl2 = inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs; };
    modules = [ (import ./wsl.nix) ];
  };

  #pi= mkSystem (import ./wsl.nix);
}
