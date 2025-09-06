# WSL host configuration
{ inputs, ... }:

{
  # No hardware configuration for WSL

  system.stateVersion = "23.11";

  # Enable WSL profile
  modules.my.wsl.enable = true;

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
