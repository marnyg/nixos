# Standalone Home Manager configurations
{ inputs, lib, ... }:

let
  # Helper to create home-manager configuration
  homeManagerFor = system: username: modules:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      extraSpecialArgs = { inherit inputs; };
      modules = [
        # Import all home modules
        { imports = lib.attrValues (import ../modules/home); }

        # Basic configuration
        {
          home.username = username;
          home.homeDirectory = "/home/${username}";
          home.stateVersion = "23.11";
        }
      ] ++ modules;
    };

in
{
  # Standalone home configurations for systems without NixOS
  flake.homeConfigurations = {
    # Example standalone home config
    "mar@standalone" = homeManagerFor "x86_64-linux" "mar" [
      {
        modules = {
          sharedDefaults.enable = true;
          nixvim.enable = true;
          fish.enable = true;
          git.enable = true;
          direnv.enable = true;
          tmux.enable = true;
          myPackages.enable = true;
        };
      }
    ];
  };
}
