{ pkgs, ... }:

{
  # Development packages
  packages = with pkgs; [ ];

  # Shell hook
  enterShell = ''
    echo "🚀 NixOS Development Environment (via devenv)"
    echo "Available hosts: wsl, desktop, laptop, miniVm"
    echo ""
    echo "Commands:"
    echo "  nix build .#nixosConfigurations.<host>.config.system.build.toplevel"
    echo "  nixos-rebuild switch --flake .#<host> (on NixOS)"
    echo "  nix run .#<host> (to test VM)"
    echo ""
  '';

  # Git hooks configuration
  pre-commit.hooks = {
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

  # Languages support (optional, add as needed)
  languages = {
    nix.enable = true;
  };
}
