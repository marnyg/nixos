# Development shells flake module
{ inputs, ... }:

{
  imports = [
    inputs.devenv.flakeModule
  ];

  perSystem = { pkgs, ... }: {
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

        # Git hooks configuration
        git-hooks = {
          hooks = {
            nixpkgs-fmt.enable = true;
            deadnix.enable = true;
            nil.enable = true;
            typos = {
              enable = true;
              settings.ignored-words = [ "noice" ];
              stages = [ "manual" ];
            };
            commitizen.enable = true;
            yamlfmt.enable = true;
          };
        };
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

    # devenv automatically creates devShells, so we don't need to manually define them
  };
}
