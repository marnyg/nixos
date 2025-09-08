# Minimal Mac host configuration
{ pkgs, ... }:
{
  # Host identification
  networking.hostName = "mac-minimal";
  networking.computerName = "Mac Minimal";
  networking.localHostName = "mac-minimal";

  # Minimal setup - no additional packages
  # Everything comes from the profile
}
