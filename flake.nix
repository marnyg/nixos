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


    #neovim-nightly-overlay = {
    #    url = "github:nix-community/neovim-nightly-overlay";
    #    inputs.nixpkgs.follows = "nixpkgs";
    #};
  };

  outputs = { home-manager, nixpkgs, nur, ... }: {
    nixosConfigurations = {

      # Laptop config
      marlaptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          ./config/machines/laptop.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.mar = import ./config/homemanager/users/mar.nix;
            nixpkgs.overlays = [
              nur.overlay
              # neovim-nightly-overlay.overlay 
            ];
          }
        ];
      };

      # Desktop config
      mardesk = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          ./config/machines/desktop.nix
          ./config/systemModules/syncthingService.nix
          ./config/systemModules/tailscaleService.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.mar = import ./config/homemanager/users/mar.nix;
            users.users.mar = {
              isNormalUser = true;
              extraGroups = [ "docker" "networkmanager" "wheel" "qemu-libvirtd" "libvirtd" ]; # Enable ‘sudo’ for the user.
            };

            home-manager.users.hmTest = import ./config/homemanager/users/hmTest.nix;
            users.users.hmTest.isNormalUser = true;

            nixpkgs.overlays = [
              nur.overlay # neovim-nightly-overlay.overlay 
            ];
          }
        ];
      };
      # Desktop config
      new = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./min-configuration.nix
          ./hardware-configuration.nix #./config/packages.nix 
          #home-manager.nixosModules.home-manager {
          #    home-manager.useGlobalPkgs = true;
          #    home-manager.useUserPackages = true;
          #    home-manager.users.mar = import ./config/home.nix;
          #    nixpkgs.overlays = [ 
          #        nur.overlay # neovim-nightly-overlay.overlay 
          #    ];
          #}
        ];
      };

      # Raspberry Pi config
      notuspi = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          ./config/pi.nix
        ];
      };
    };
  };
}
