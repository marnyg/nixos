# Darwin/macOS configuration using nix-darwin
# This module defines the Mac system configuration using the modular structure
{ inputs, self, config, ... }:
{
  flake.darwinConfigurations.mac = inputs.darwin.lib.darwinSystem {
    system = "aarch64-darwin";

    modules = [
      # Host-specific configuration
      ./default.nix

      # Import Darwin modules bundle
      self.darwinModules.default

      # External inputs
      inputs.home-manager.darwinModules.home-manager

      {
        # Nixpkgs configuration
        nixpkgs = {
          config.allowUnfree = true;
          overlays = [
            self.overlays.default
            self.overlays.nur
            (inputs.ghostty-darwin-overlay.overlay { githubToken = ""; })
            (_: super: {
              ghostty = super.ghostty-darwin.overrideAttrs (oldAttrs: {
                meta = (oldAttrs.meta or { }) // {
                  mainProgram = "ghostty";
                };
              });
            })
          ];
        };

        # Home-manager configuration
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = { inherit inputs; };
          sharedModules = [
            self.homeManagerModules.default
            inputs.mac-app-util.homeManagerModules.default
          ];
          users.mariusnygard = import ../../users/mar/home-mac.nix;
        };

        # User configuration
        users.users.mariusnygard = {
          home = "/Users/mariusnygard";
        };
      }
    ];

    specialArgs = {
      inherit inputs self;
      userRegistry = config.flake-parts.userRegistry;
      homeModules = config.flake-parts.homeModules;
      secretPaths = config.flake-parts.secretPaths;
    };
  };
}
