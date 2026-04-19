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
    # Monitor patterns use fallback chains: first match wins, falls back to
    # main/secondary when a specific display isn't connected (e.g. undocked).
    windowManagement.workspaces = [
      { number = 1; label = "code"; monitor = [ "Odyssey G70B" "main" ]; apps = [ "Visual Studio Code" "Ghostty" "Xcode" ]; }
      { number = 2; label = "web"; monitor = [ "Odyssey G70B" "main" ]; apps = [ "Arc" "Safari" "Firefox" ]; }
      { number = 3; label = "todo"; monitor = [ "Odyssey G70B" "main" ]; apps = [ "Reminder" "Mail" "Calendar" ]; }
      { number = 4; label = "utils"; monitor = [ "VG272" "secondary" ]; apps = [ "Spotify" "Music" "Finder" ]; }
      { number = 5; label = "chat"; monitor = [ "VG272" "secondary" ]; apps = [ "Slack" "Signal" "Messages" "Discord" "Microsoft Teams" "Microsoft Outlook" ]; }
    ];

    # Key remapping
    services.karabiner = {
      enable = true;

      rules =
        let
          # Terminal apps where Ctrl+C must stay as SIGINT
          terminalApps = [
            "^com\\.mitchellh\\.ghostty"
            "^com\\.apple\\.Terminal"
            "^com\\.googlecode\\.iterm2"
          ];
          # Remap Ctrl to Cmd for a key, excluding terminals
          ctrlToCmd = key: {
            type = "basic";
            conditions = [{ type = "frontmost_application_unless"; bundle_identifiers = terminalApps; }];
            from = { key_code = key; modifiers.mandatory = [ "control" ]; };
            to = [{ key_code = key; modifiers = [ "command" ]; }];
          };
        in
        [
          {
            description = "Ctrl+C/V/X/A/Z to Cmd+C/V/X/A/Z (except terminals)";
            manipulators = map ctrlToCmd [ "c" "v" "x" "a" "z" "t" "w" "n" "f" "s" "l" "r" "p" ];
          }
        ];
    };

    # Additional brew packages specific to this machine
    brew.casks = lib.mkAfter [
      "obsidian"
      "notion"
    ];
  };

  # User shell preference (overrides profile default)
  users.users.mariusnygard.shell = pkgs.fish;
}
