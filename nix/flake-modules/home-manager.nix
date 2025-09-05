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
  perSystem = { pkgs, system, ... }: {
    # Per-system packages or checks could go here if needed
    packages.home-example = homeManagerFor pkgs "mar" [
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
        };
      }
    ];
  };
}
