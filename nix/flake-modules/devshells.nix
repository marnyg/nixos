# Development shells flake module
{ ... }:

{
  perSystem = { pkgs, ... }: {
    # Development shells
    devShells = {
      # Default shell for NixOS development
      default = pkgs.mkShell {
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

        shellHook = ''
          echo "🚀 NixOS Development Environment"
          echo "Available hosts: wsl, desktop, laptop, miniVm"
          echo ""
          echo "Commands:"
          echo "  nix build .#nixosConfigurations.<host>.config.system.build.toplevel"
          echo "  nixos-rebuild switch --flake .#<host> (on NixOS)"
          echo "  nix run .#<host> (to test VM)"
          echo ""
        '';

        EDITOR = "vim";
      };

      # Shell for working on packages
      packages = pkgs.mkShell {
        packages = with pkgs; [
          # Package development tools
          nix-build-uncached
          nix-update
          nixpkgs-review
        ];
      };
    };
  };
}
