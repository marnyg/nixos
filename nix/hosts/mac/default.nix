# Mac host-specific configuration
# This file contains only host-specific settings
# Common Darwin settings are in the profile modules
{ pkgs, self, ... }:
{
  # Host identification
  networking.hostName = "marius-mac";
  networking.computerName = "Marius's MacBook";
  networking.localHostName = "marius-mac";

  # Add nixvim if available
  environment.systemPackages =
    if (self ? packages.${pkgs.system}.nixvim)
    then [ self.packages.${pkgs.system}.nixvim ]
    else [ ];

  # User shell preference (overrides profile default)
  users.users.mariusnygard.shell = pkgs.fish;
}
