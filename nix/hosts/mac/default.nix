# Mac host-specific configuration
# This file contains only host-specific settings
# Common Darwin settings are in the profile modules
{ pkgs, lib, self, ... }:
{
  # Use the workstation profile
  imports = [ self.darwinModules.profile-workstation ];
  nix.enable = false;

  # Host identification
  networking.hostName = "marius-mac";
  networking.computerName = "Marius's MacBook";
  networking.localHostName = "marius-mac";

  # Host-specific overrides
  modules.darwin = {
    # Custom workspace configuration for this machine
    windowManagement.workspaces = [
      { number = 1; label = "code"; monitor = "main"; apps = [ "Visual Studio Code" "Ghostty" "Xcode" ]; }
      { number = 2; label = "web"; monitor = "main"; apps = [ "Arc" "Safari" "Firefox" ]; }
      { number = 3; label = "todo"; monitor = "main"; apps = [ "Reminder" "Mail" "Calendar" ]; }
      { number = 4; label = "utils"; monitor = "secondary"; apps = [ "Spotify" "Music" "Finder" ]; }
      { number = 5; label = "chat"; monitor = "secondary"; apps = [ "Slack" "Signal" "Messages" "Discord" "Microsoft Teams" "Microsoft Outlook" ]; }
    ];

    # Additional brew packages specific to this machine
    brew.casks = lib.mkAfter [
      "obsidian"
      "notion"
    ];
  };

  # User shell preference (overrides profile default)
  users.users.mariusnygard.shell = pkgs.fish;
}
