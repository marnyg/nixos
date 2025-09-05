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

        devenv.root = "${../..}";

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
            statix = {
              enable = true;
              settings.format = "stderr";
            };
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

      # Agentic DM development shell
      agentic-dm = {
        name = "agentic-dm-dev";
        languages.elixir.enable = true;
        devenv.root = "${../../pkgs/agentic-dm/agentic_dm}";

        enterShell = ''
          echo "🎲 Agentic DM Development Environment"
          echo "Elixir project for AI-powered tabletop RPG assistant"
          echo ""
          echo "Available commands:"
          echo "  mix deps.get"
          echo "  mix compile" 
          echo "  mix test"
        '';
      };
    };

    # devenv automatically creates devShells, so we don't need to manually define them
  };
}
