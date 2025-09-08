# Minimal Darwin/macOS configuration
# Example of using the minimal profile without window management
{ inputs, self, config, ... }:
{
  flake.darwinConfigurations.mac-minimal = inputs.darwin.lib.darwinSystem {
    system = "aarch64-darwin";

    modules = [
      # Host-specific configuration
      ./default.nix

      # Use the minimal profile (no Yabai/skhd)
      self.darwinModules.profile-minimal

      # External inputs
      inputs.home-manager.darwinModules.home-manager

      {
        # Nixpkgs configuration
        nixpkgs = {
          config.allowUnfree = true;
          overlays = [
            self.overlays.default
            self.overlays.nur
          ];
        };

        # Home-manager configuration
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = { inherit inputs; };
          sharedModules = [
            self.homeManagerModules.default
          ];
          users.mariusnygard = import ../../users/mar/home-mac.nix;
        };

        # User configuration
        users.users.mariusnygard = {
          home = "/Users/mariusnygard";
          shell = inputs.nixpkgs.legacyPackages.aarch64-darwin.fish;
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
