# Darwin workstation profile
# Configures a full-featured macOS development workstation
{ pkgs, lib, ... }:
{
  # Import core modules and services
  imports = [
    ../core/defaults.nix
    ../core/nix-settings.nix # Now optimized for macOS performance
    ../core/fonts.nix
    ../services/yabai.nix
    ../services/skhd.nix
    ../services/tailscale.nix
  ];

  # Enable and configure services
  modules.darwin.services.yabai = {
    enable = true;
    layout = "bsp";
    workspaces = {
      "1" = { label = "todo"; apps = [ "Reminder" "Mail" "Calendar" ]; };
      "2" = { label = "code"; apps = [ "Visual Studio Code" "IntelliJ IDEA" "Xcode" ]; };
      "3" = { label = "productive"; apps = [ "Alacritty" "Arc" "Safari" "Firefox" ]; };
      "4" = { label = "utils"; apps = [ "Spotify" "Music" "Finder" ]; };
      "5" = { label = "chat"; apps = [ "Microsoft Teams" "Slack" "Signal" "Messages" "Discord" ]; };
    };
  };

  modules.darwin.services.skhd = {
    enable = true;
    defaultKeybindings = true;
  };

  modules.darwin.services.tailscale.enable = true;

  # Additional system packages
  environment.systemPackages = with pkgs; [
    terminal-notifier
    mas # Mac App Store CLI
    cocoapods
  ];

  # Enable specific shells
  environment.shells = [ pkgs.fish pkgs.zsh pkgs.bash ];

  # User configuration
  system.primaryUser = lib.mkDefault "mariusnygard";
}
