# Minimal Darwin profile
# Basic macOS configuration without window management
{ pkgs, ... }:
{
  # Import core modules only
  imports = [
    ../core/defaults.nix
    ../core/nix-settings.nix
  ];

  # Basic packages only
  environment.systemPackages = with pkgs; [
    terminal-notifier
  ];

  # Enable basic shells
  environment.shells = [ pkgs.fish pkgs.zsh pkgs.bash ];
}
