{ pkgs, lib, config, ... }:
with lib;
{
  options.myModules.wsl = {
    enable = mkEnableOption "enable wsl with my default";
  };

  config = mkIf config.myModules.wsl.enable {
    wsl = {
      enable = true;
      wslConf.automount.root = "/mnt";
      defaultUser = "mar";
      startMenuLaunchers = true;

      # Enable native Docker support
      docker-native.enable = true;
      # Enable integration with Docker Desktop (needs to be installed)
      #docker-desktop.enable = true;
    };
    users.users.mar = { shell = pkgs.zsh; };
  };
}
