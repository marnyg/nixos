# Laptop host configuration
{ ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/nixos/profiles/laptop.nix
  ];

  system.stateVersion = "23.11";

  # No specific hardware overrides needed - laptop profile handles it all

  # Second NetBird client so the work mesh and the home mesh (default
  # client, wt0) are up simultaneously. Driven with
  # `netbird-swone up|down|status`; needs one interactive SSO login.
  modules.nixos.services.netbird.instances.swone = {
    managementUrl = "https://vpn.swonefinops.com";
    wireguardPort = 51821;
  };

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
