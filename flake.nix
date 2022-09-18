{
  description = "NixOS configuration";

  # All inputs for the system
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    my-nvim = {
      #url = "git+file:///home/mar/git/nvim-conf";
      inputs.nixpkgs.follows = "nixpkgs";
      type = "github";
      owner = "marnyg";
      repo = "nvim-conf";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    # inspiration: https://github.com/pinpox/nixos/blob/main/flake.nix
    nixosModules = [ ];
    homeManagerModules = [ ];
    homeConfigurations = [ ];

    nixosConfigurations = {
      full = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { flake-self = self; } // inputs;
        modules = [ .config/marchines/marDesk/configuration.nix ];
      };


      # Laptop config
      marlaptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          ./config/machines/laptop.nix
          ./config/systemModules/syncthingService.nix
          ./config/systemModules/tailscaleService.nix
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            nixpkgs.overlays = [ inputs.nur.overlay inputs.my-nvim.overlay.x86_64-linux ];

            imports = [
              ./config/homemanager/users/mar.nix
            ];
          }
        ];
      };

      # Desktop config
      mardesk = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        # pkgs = nixpkgsFor.${system};
        modules = [
          ./configuration.nix
          ./config/machines/desktop.nix
          ./config/systemModules/syncthingService.nix
          ./config/systemModules/tailscaleService.nix
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            nixpkgs.overlays = [ inputs.nur.overlay inputs.my-nvim.overlay.x86_64-linux ];

            imports = [
              ./config/homemanager/users/mar.nix
            ];

          }
        ];
      };

      # wsl config
      mar-wsl = {
        #system = "x86_64-linux";
        # pkgs = nixpkgsFor.${system};
        modules = [
          ./configuration.nix
          #./config/machines/desktop.nix
          #./config/systemModules/syncthingService.nix
          ./config/systemModules/tailscaleService.nix
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            nixpkgs.overlays = [ inputs.nur.overlay inputs.my-nvim.overlays.default ];

            imports = [
              ./config/homemanager/users/mar.nix
            ];
          }
        ];
      };

      # Desktop config
      new = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./min-configuration.nix ./hardware-configuration.nix ];
      };

      # Raspberry Pi config
      notuspi = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./configuration.nix ./config/pi.nix ];
      };
    };
  };
}
