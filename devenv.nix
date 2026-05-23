{ pkgs, ... }:

{
  # Development packages
  packages = with pkgs; [ worktrunk ];

  # Shell hook
  enterShell = ''
    # Worktrunk (`wt`) shell integration — devenv spawns bash, so the
    # fish-side integration from the home-manager worktrunk module doesn't
    # apply here. Without this, `wt remove` can't cd out of the doomed
    # worktree before deletion, leaving the shell stranded.
    if command -v wt >/dev/null 2>&1; then
        eval "$(${pkgs.worktrunk}/bin/wt config shell init bash)"
    fi

    echo "🚀 NixOS Development Environment (via devenv)"
    echo "Available hosts: wsl, desktop, laptop, mac"
    echo ""
    echo "Commands:"
    echo "  nix build .#nixosConfigurations.<host>.config.system.build.toplevel"
    echo "  nixos-rebuild switch --flake .#<host> (on NixOS)"
    echo "  darwin-rebuild switch --flake .#mac (on macOS)"
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
