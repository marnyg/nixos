{ pkgs, ... }:

{
  # Development packages
  packages = with pkgs; [ ];

  # Shell hook
  enterShell = ''
    echo "🚀 NixOS Development Environment (via devenv)"
    echo "Available hosts: wsl, desktop, laptop"
    echo ""
    echo "Commands:"
    echo "  nix build .#nixosConfigurations.<host>.config.system.build.toplevel"
    echo "  nixos-rebuild switch --flake .#<host> (on NixOS)"
    echo "  nix run .#<host> (to test VM)"
    echo ""
  '';

  # Pre-commit hooks configuration
  git-hooks.hooks = {
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

  # Languages support (add as needed for specific project development)
  languages = {
    nix.enable = true;
  };

  # Development-specific tools can be added here:
  # - Scripts for automation
  # - Task runners
  # - Language servers and tools
  # - Local development processes
  # - Services (databases, etc.)
  # - Containers for testing
}
