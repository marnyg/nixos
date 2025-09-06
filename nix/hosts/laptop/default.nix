# Laptop host configuration
{ inputs, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/nixos/profiles/laptop.nix
  ];

  system.stateVersion = "23.11";

  # Laptop-specific: battery optimization
  hardware.acpilight.enable = true;

  # User configuration
  my.users.mar = {
    enable = true;
    enableHome = true;
    profiles = [ "developer" "desktop" ];

    extraSystemConfig = {
      extraGroups = [ "networkmanager" "audio" "video" "render" ];
    };
  };
}
