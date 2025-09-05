# NixOS configurations flake module
{ self, lib, inputs, ... }:

let

  # Helper function to create NixOS system
  nixosSystemFor = system: hostPath:
    lib.nixosSystem {
      inherit system;
      specialArgs = { inherit lib inputs; };
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
        {
          nixpkgs = {
            config.allowUnfree = true;
            overlays = [
              inputs.nur.overlays.default
              (final: _prev: {
                mcphub-nvim = inputs.mcphub-nvim.packages.${final.system}.default or null;
                mcphub = inputs.mcphub.packages.${final.system}.default or null;
              })
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
  vmApp = name:
    let
      vmScript = self.nixosConfigurations.${name}.config.system.build.vm;
      # The VM script name includes the hostname
      hostname = self.nixosConfigurations.${name}.config.networking.hostName;
      binName = "run-${hostname}-vm";
    in
    {
      type = "app";
      program = "${vmScript}/bin/${binName}";
    };

in
{
  flake.nixosConfigurations = {
    # Production hosts
    wsl = nixosSystemFor "x86_64-linux" ../hosts/wsl;
    desktop = nixosSystemFor "x86_64-linux" ../hosts/desktop;
    laptop = nixosSystemFor "x86_64-linux" ../hosts/laptop;

    # Test/development VM
    miniVm = nixosSystemFor "x86_64-linux" ({ pkgs, modulesPath, ... }: {
      imports = [
        "${modulesPath}/virtualisation/qemu-vm.nix"
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
      users.users.mar = {
        isNormalUser = true;
        shell = pkgs.bash;
        extraGroups = [ "wheel" ];
        password = "123";
      };

      # Enable basic modules for testing
      my.users.mar = {
        enable = true;
        enableHome = false; # Disable home-manager for simplest test
        profiles = [ ];
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
    # VM apps for easy testing
    apps = {
      wsl = vmApp "wsl";
      desktop = vmApp "desktop";
      laptop = vmApp "laptop";
      miniVm = vmApp "miniVm";
    };
  };
}
