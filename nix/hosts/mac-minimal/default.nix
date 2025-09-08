# Minimal Mac host configuration
{ self, ... }:
{
  # Use the minimal profile
  imports = [ self.darwinModules.profile-minimal ];

  # Host identification
  networking.hostName = "mac-minimal";
  networking.computerName = "Mac Minimal";
  networking.localHostName = "mac-minimal";

  # Minimal setup - no additional packages
  # Everything comes from the profile
}
