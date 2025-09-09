# WSL host configuration
{ ... }:

{
  imports = [
    ../../modules/nixos/core/nix-network-settings.nix
  ];

  # No hardware configuration for WSL

  system.stateVersion = "23.11";

  # Enable WSL profile
  modules.my.wsl.enable = true;

  # Enable enhanced network timeout settings
  modules.my.nixNetworkSettings.enable = true;

  # User configuration
  my.users = {
    mar = {
      enable = true;
      enableHome = true;
      profiles = [ "developer" ];
    };

    testUser = {
      enable = true;
      enableHome = true;
      profiles = [ "minimal" ];
    };
  };
}
