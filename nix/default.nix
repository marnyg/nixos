# Module System Architecture
# 
# This file serves as the entry point for the flake-parts module system.
# It imports all flake modules that define different aspects of the configuration:
#
# - systems.nix: Defines supported system architectures (x86_64-linux, aarch64-linux, etc.)
# - overlays.nix: Package overlays and modifications to nixpkgs
# - nixos.nix: NixOS system configurations for all hosts
# - home-manager.nix: Home Manager configurations and integration
# - devshells.nix: Development environments and shells
# - packages.nix: Custom packages and derivations
#
# The modular structure allows for:
# 1. Clear separation of concerns
# 2. Easier testing of individual components
# 3. Reusability across different hosts
# 4. Simplified maintenance and updates

{
  imports = [
    # Core flake-parts modules for better organization
    ./flake-modules/systems.nix
    ./flake-modules/overlays.nix
    ./flake-modules/home-manager.nix
    ./flake-modules/devshells.nix
    ./flake-modules/packages.nix
    ./flake-modules/darwin-rebuild.nix

    # Localized module registries
    ./modules/home/flake-module.nix
    ./modules/nixos/flake-module.nix
    ./modules/darwin/flake-module.nix
    ./users/flake-module.nix

    # Host configurations with localized imports
    ./hosts/desktop/flake-module.nix
    ./hosts/laptop/flake-module.nix
    ./hosts/wsl/flake-module.nix
    ./hosts/mac/flake-module.nix
  ];
}
