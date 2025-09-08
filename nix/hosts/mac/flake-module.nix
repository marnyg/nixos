# Darwin/macOS configuration using nix-darwin
# This module defines the Mac system configuration using the modular structure
{ inputs, self, config, ... }:
{
  flake.darwinConfigurations.mac = inputs.darwin.lib.darwinSystem {
    system = "aarch64-darwin";

    modules = [
      # Host-specific configuration
      ./default.nix

      # Use the simplified workstation profile
      (import ../../modules/darwin/profiles/workstation-simple.nix)

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
            # FIXME: Remove when nodejs-22.18.0 test failures are fixed upstream
            # Tests failing on Darwin: test-fs-stat-bigint, test-dgram-udp6-link-local-address, test-inspector-ip-detection
            # (final: prev: {
            #   nodejs_22 = prev.nodejs_22.overrideAttrs (oldAttrs: {
            #     doCheck = false;
            #     doInstallCheck = false;
            #   });
            #   nodejs = prev.nodejs.overrideAttrs (oldAttrs: {
            #     doCheck = false;
            #     doInstallCheck = false;
            #   });
            # })
            # FIXME: Remove when python3.13-aiohttp-3.12.15 test failures are fixed upstream
            # Test failing on Darwin: test_static_file_ssl
            (final: prev: {
              python313 = prev.python313.override {
                packageOverrides = python-self: python-super: {
                  aiohttp = python-super.aiohttp.overrideAttrs (oldAttrs: {
                    doCheck = false;
                    doInstallCheck = false;
                  });
                  black = python-super.black.overrideAttrs (oldAttrs: {
                    doCheck = false; # Depends on aiohttp
                  });
                  paintcompiler = python-super.paintcompiler.overrideAttrs (oldAttrs: {
                    doCheck = false; # Depends on aiohttp
                  });
                  gftools = python-super.gftools.overrideAttrs (oldAttrs: {
                    doCheck = false; # Depends on aiohttp
                  });
                };
              };
            })
            # FIXME: Remove when python3.13-sh-2.2.2 test failure is fixed upstream
            # Issue: test_done_callback_no_deadlock fails with pytest OSError on Darwin
            # Error: "pytest: reading from stdin while output is captured!"
            # This affects multiple packages that depend on python3.13-sh including:
            # - jetbrains-mono font build process
            # - various Python development tools
            # Test with: nix-build '<nixpkgs>' -A python313Packages.sh
            # (final: prev: {
            #   python313 = prev.python313.override {
            #     packageOverrides = python-self: python-super: {
            #       sh = python-super.sh.overrideAttrs (oldAttrs: {
            #         # Disable the failing test on Darwin
            #         disabledTests = (oldAttrs.disabledTests or []) ++ [
            #           "test_done_callback_no_deadlock"
            #         ];
            #       });
            #     };
            #   };
            # })
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
