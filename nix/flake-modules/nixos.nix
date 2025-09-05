# NixOS configurations flake module
#
# This module defines all NixOS system configurations and provides helper
# functions for building and testing them. It uses flake-parts to organize
# the configurations in a modular way.

{ self, lib, inputs, ... }:

let
  # Helper function to create NixOS system
  # This wraps lib.nixosSystem with our standard module imports and configuration
  # Parameters:
  #   system: The system architecture (e.g., "x86_64-linux")
  #   hostPath: Path to the host's configuration directory
  nixosSystemFor = system: hostPath:
    lib.nixosSystem {
      inherit system;
      specialArgs = { inherit lib inputs; }; # Make flake inputs available to modules
      modules = [
        # Import the host configuration
        hostPath

        # Core NixOS modules
        ../modules/nixos/core/users.nix
        ../modules/nixos/core/defaults.nix

        # Input modules
        inputs.home-manager.nixosModules.home-manager
        inputs.nixos-wsl.nixosModules.wsl
        inputs.nur.modules.nixos.default
        inputs.microvm.nixosModules.host

        # System-wide nixpkgs configuration
        # Import the overlays defined in overlays.nix for consistency
        {
          nixpkgs = {
            config.allowUnfree = true; # Required for nvidia drivers, spotify, etc.
            overlays = with self.overlays; [
              default # Custom packages (mcphub, etc.)
              nur # NUR packages
            ];
          };
        }

        # Home-manager integration
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;

            # Make inputs available to home-manager
            extraSpecialArgs = { inherit inputs; };

            # Import all home modules for user configs
            sharedModules = [
              { imports = lib.attrValues (import ../modules/home { inherit inputs; }); }
            ];
          };
        }
      ];
    };

  # VM app helper
  # Creates a nix app that runs a NixOS configuration as a QEMU VM
  # This is useful for testing configurations without deploying to hardware
  # Usage: nix run .#<hostname>
  vmApp = name:
    let
      vmScript = self.nixosConfigurations.${name}.config.system.build.vm;
      # The VM script name includes the hostname from the configuration
      hostname = self.nixosConfigurations.${name}.config.networking.hostName;
      binName = "run-${hostname}-vm";
    in
    {
      type = "app";
      program = "${vmScript}/bin/${binName}";
      meta.description = "Run ${name} NixOS configuration as a virtual machine";
    };

in
{
  flake.nixosConfigurations = {
    # Production hosts
    wsl = nixosSystemFor "x86_64-linux" ../hosts/wsl;
    desktop = nixosSystemFor "x86_64-linux" ../hosts/desktop;
    laptop = nixosSystemFor "x86_64-linux" ../hosts/laptop;

    # Test/development VM
    # Minimal VM configuration for testing the module system and basic functionality
    # This VM can be run with: nix run .#miniVm
    miniVm = nixosSystemFor "x86_64-linux" ({ modulesPath, ... }: {
      imports = [
        "${modulesPath}/virtualisation/qemu-vm.nix" # QEMU VM support
      ];

      # VM configuration
      virtualisation = {
        memorySize = 2048;
        diskSize = 8192;
        graphics = false;
        qemu.options = [ "-nographic" "-serial" "mon:stdio" ];
      };

      # Boot configuration
      boot.loader.grub.device = "/dev/vda";

      # Filesystem configuration
      fileSystems."/" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
      };

      # Simple VM configuration for testing
      # Use the my.users system instead of defining users directly
      my.users.mar = {
        enable = true;
        enableHome = false; # Disable home-manager for simplest test
        profiles = [ ];
        extraSystemConfig = {
          password = "123"; # Simple password for VM testing
        };
      };

      # Enable SSH for easy access
      services.openssh = {
        enable = true;
        settings.PermitRootLogin = "yes";
      };

      # Networking
      networking = {
        hostName = "nixos-test-vm";
        firewall.enable = false; # For testing convenience
      };

      system.stateVersion = "23.11";
    });
  };

  perSystem = { ... }: {
    apps = {
      # Note: WSL configurations cannot be run as VMs
      desktop = vmApp "desktop";
      laptop = vmApp "laptop";
      miniVm = vmApp "miniVm";
    };
  };
}
