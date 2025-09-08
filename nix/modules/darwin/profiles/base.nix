# Base Darwin profile
# Essential configuration for all Darwin systems
{ lib, pkgs, ... }:
{
  # Core modules that every Darwin system needs
  modules.darwin = {
    defaults.enable = true;
    nixSettings.enable = true;
  };

  # Essential system packages
  environment.systemPackages = with pkgs; [
    git
    vim
    curl
    wget
    coreutils
    jq # Required for window manager keybindings
  ];

  # System state version
  system.stateVersion = lib.mkDefault 6;

  # Enable Touch ID for sudo by default
  security.pam.services.sudo_local.touchIdAuth = lib.mkDefault true;

  # Basic shell support
  programs.zsh.enable = true;
  programs.bash.enable = true;
}
