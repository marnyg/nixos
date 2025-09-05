# New NixOS configuration structure
{
  imports = [
    # Flake-parts modules for better organization
    ./flake-modules/systems.nix
    ./flake-modules/overlays.nix
    ./flake-modules/nixos.nix
    ./flake-modules/home-manager.nix
    ./flake-modules/devshells.nix
    ./flake-modules/packages.nix
  ];
}
