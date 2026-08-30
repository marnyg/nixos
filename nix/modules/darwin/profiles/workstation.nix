# Full workstation Darwin profile
# Complete development workstation with window management
{ lib, pkgs, ... }:
{
  imports = [ ./developer.nix ];

  # Workstation modules
  modules.darwin = {
    # Window management
    windowManagement = {
      enable = true;
      layout = lib.mkDefault "bsp";

      workspaces = lib.mkDefault [
        { number = 1; label = "todo"; apps = [ "Reminder" "Mail" "Calendar" ]; }
        { number = 2; label = "code"; apps = [ "Visual Studio Code" "IntelliJ IDEA" "Xcode" ]; }
        { number = 3; label = "productive"; apps = [ "Alacritty" "Arc" "Safari" "Firefox" ]; }
        { number = 4; label = "utils"; apps = [ "Spotify" "Music" "Finder" ]; }
        { number = 5; label = "chat"; apps = [ "Microsoft Teams" "Slack" "Signal" "Messages" "Discord" ]; }
      ];

      rules = lib.mkDefault [
        { app = "^System Settings$"; manage = false; }
        { app = "^System Information$"; manage = false; }
        { app = "^System Preferences$"; manage = false; }
        { title = "Preferences$"; manage = false; }
        { title = "Settings$"; manage = false; }
      ];
    };

  };

  # Tailscale VPN
  services.tailscale.enable = lib.mkDefault true;

  # Netbird VPN daemon (creates /var/run/netbird/sock for `netbird up`)
  services.netbird.enable = lib.mkDefault true;

  # Additional workstation packages
  environment.systemPackages = with pkgs; [
    terminal-notifier
    mas # Mac App Store CLI
    cocoapods
  ];

  # Fonts for development
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    fira-code
    source-code-pro
  ];

  # System primary user
  system.primaryUser = lib.mkDefault "mariusnygard";
}
