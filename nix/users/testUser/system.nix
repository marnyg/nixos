# System-level configuration for user 'testUser'
{ pkgs, ... }:

{
  # Basic user settings
  isNormalUser = true;
  description = "Test User";

  # Groups membership
  extraGroups = [
    # No sudo access for test user
  ];

  # Shell configuration
  shell = pkgs.bash;

  # SSH configuration
  openssh.authorizedKeys.keys = [
    # Add SSH keys if needed
  ];

  # User-specific packages that should always be available at system level
  packages = with pkgs; [
    # Basic tools only
    vim
    wget
    curl
  ];
}
