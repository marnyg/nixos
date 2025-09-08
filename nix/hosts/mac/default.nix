# Mac host-specific configuration
# This file contains only host-specific settings
# Common Darwin settings are in the profile modules
{ pkgs, self, lib, ... }:
{
  # Use the workstation profile
  imports = [ self.darwinModules.profile-workstation ];

  # Host identification
  networking.hostName = "marius-mac";
  networking.computerName = "Marius's MacBook";
  networking.localHostName = "marius-mac";

  # Host-specific overrides
  modules.darwin = {
    # Custom workspace configuration for this machine
    windowManagement.workspaces = [
      { number = 1; label = "todo"; apps = [ "Reminder" "Mail" "Calendar" ]; }
      { number = 2; label = "code"; apps = [ "Visual Studio Code" "Ghostty" "Xcode" ]; }
      { number = 3; label = "web"; apps = [ "Arc" "Safari" "Firefox" ]; }
      { number = 4; label = "utils"; apps = [ "Spotify" "Music" "Finder" ]; }
      { number = 5; label = "chat"; apps = [ "Slack" "Signal" "Messages" "Discord" ]; }
    ];

    # Additional brew packages specific to this machine
    brew.casks = lib.mkAfter [
      "obsidian"
      "notion"
    ];
  };

  # Add nixvim if available
  environment.systemPackages =
    if (self ? packages.${pkgs.system}.nixvim)
    then [ self.packages.${pkgs.system}.nixvim ]
    else [ ];

  # User shell preference (overrides profile default)
  users.users.mariusnygard.shell = pkgs.fish;
}
