# Laptop host configuration
{ ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/nixos/profiles/laptop.nix
  ];

  system.stateVersion = "23.11";

  # No specific hardware overrides needed - laptop profile handles it all

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
