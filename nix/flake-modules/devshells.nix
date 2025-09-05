# Development shells flake module
{ inputs, ... }:

{
  imports = [
    inputs.devenv.flakeModule
  ];

  perSystem = { config, pkgs, ... }: {
    # Development shells
    devenv.shells = {
      # Default shell for NixOS development
      default = {
        packages = with pkgs; [
          # Nix tools
          nixpkgs-fmt
          nil
          nix-tree
          nix-diff

          # System tools
          git
          vim

          # Flake tools
          fh # Flake helper
        ];

        env = {
          EDITOR = "vim";
        };

        enterShell = ''
          echo "🚀 NixOS Development Environment"
          echo "Available hosts: wsl, desktop, laptop, miniVm"
          echo ""
          echo "Commands:"
          echo "  nix build .#nixosConfigurations.<host>.config.system.build.toplevel"
          echo "  nixos-rebuild switch --flake .#<host> (on NixOS)"
          echo "  nix run .#<host> (to test VM)"
          echo ""
        '';
      };

      # Shell for working on packages
      packages = {
        packages = with pkgs; [
          # Package development tools
          nix-build-uncached
          nix-update
          nixpkgs-review
        ];
      };
    };

    # Keep the old devShells for compatibility
    devShells = {
      default = config.devenv.shells.default.env;
      packages = config.devenv.shells.packages.env;
    };
  };
}
