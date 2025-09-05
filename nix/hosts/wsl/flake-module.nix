{ inputs, self, config, ... }:
{
  flake.nixosConfigurations.wsl = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./default.nix

      # Import shared modules from flake outputs
      self.nixosModules.core-defaults
      self.nixosModules.core-secrets
      self.nixosModules.core-nixSettings
      self.nixosModules.core-users
      self.nixosModules.profile-wsl

      # External inputs
      inputs.nixos-wsl.nixosModules.wsl
      inputs.agenix.nixosModules.age
      inputs.home-manager.nixosModules.home-manager
      {
        nixpkgs = {
          config.allowUnfree = true;
          overlays = [
            self.overlays.default
            self.overlays.nur
          ];
        };

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = { inherit inputs; };
          sharedModules = [ self.homeManagerModules.default ];
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

