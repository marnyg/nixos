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
      url = "git+file:///home/mar/git/nvim-conf";
      inputs.nixpkgs.follows = "nixpkgs";

      #inputs.nixpkgs.follows = "nixpkgs";
      #type = "github";
      #owner = "marnyg";
      #repo = "nvim-conf";
      #ref = "flake";
    };
  };

  outputs = { home-manager, nixpkgs, nur, my-nvim, ... }: {
    nixosConfigurations = {

      # Laptop config
      marlaptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          ./config/machines/laptop.nix
          ./config/systemModules/syncthingService.nix
          ./config/systemModules/tailscaleService.nix
          #my-nvim
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.vm = import ./config/homemanager/users/mar.nix;
            users.users.vm = {
              isNormalUser = true;
              extraGroups = [ "docker" "networkmanager" "wheel" ]; # Enable ‘sudo’ for the user.
              initialHashedPassword = "HNTH57eGshHyQ"; #test
            };

            home-manager.users.mar = import ./config/homemanager/users/mar.nix;
            users.users.mar = {
              isNormalUser = true;
              extraGroups = [ "docker" "networkmanager" "wheel" "qemu-libvirtd" "libvirtd" ]; # Enable ‘sudo’ for the user.
            };

            nixpkgs.overlays = [
              nur.overlay
              my-nvim.overlays.default
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
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            nixpkgs.overlays = [
              nur.overlay
              my-nvim.overlays.default
            ];

            imports = [
              ./config/homemanager/users/mar.nix
              ./config/homemanager/users/vm.nix
            ];

          }
        ];
      };
      
      # wsl config
      mar-wsl = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        # pkgs = nixpkgsFor.${system};
        modules = [
          ./configuration.nix
          #./config/machines/desktop.nix
          #./config/systemModules/syncthingService.nix
          ./config/systemModules/tailscaleService.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            nixpkgs.overlays = [
              nur.overlay
              my-nvim.overlays.default
            ];

            imports = [
              ./config/homemanager/users/mar.nix
              ./config/homemanager/users/vm.nix
            ];

          }
        ];
      };

      # Desktop config
      new = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./min-configuration.nix
          ./hardware-configuration.nix
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
