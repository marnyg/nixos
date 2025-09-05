# System-level configuration for user 'mar'
{ pkgs, ... }:

{
  # Basic user settings
  isNormalUser = true;
  description = "Marius Nygård";

  # Groups membership
  extraGroups = [
    "wheel" # sudo access
    "networkmanager"
    "audio"
    "video"
    "docker"
    "libvirtd"
  ];

  # Shell configuration (will be resolved from preferences)
  shell = pkgs.fish;

  # SSH configuration
  openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBR+GCws2rQ30VOYAvIiWtbRrHfveej4H2L+/s28JTCG trash@win"
  ];

  # User-specific packages that should always be available at system level
  packages = with pkgs; [
    # Essential tools
    git
    vim
    wget
    curl
  ];
}
