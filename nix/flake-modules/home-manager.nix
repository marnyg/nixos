# Standalone Home Manager configurations
{ inputs, lib, ... }:

let
  # Helper to create home-manager configuration
  homeManagerFor = pkgs: username: modules:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { inherit inputs; };
      modules = [
        # Import all home modules
        { imports = lib.attrValues (import ../modules/home { inherit inputs; }); }

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
  # Removed perSystem packages as home-manager configurations 
  # are better accessed through homeConfigurations attribute

  # Also provide flake-level configurations for backward compatibility
  flake.homeConfigurations = {
    "mar@standalone" = homeManagerFor inputs.nixpkgs.legacyPackages.x86_64-linux "mar" [
      {
        modules = {
          sharedDefaults.enable = true;
          nixvim.enable = true;
          fish.enable = true;
          git.enable = true;
          direnv.enable = true;
          tmux.enable = true;
          myPackages.enable = true;
          secrets.enable = false; # Disabled for standalone config without agenix
        };
      }
    ];
  };
}
