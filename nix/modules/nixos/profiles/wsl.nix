{ lib, config, ... }:
with lib;
{
  options.modules.my.wsl = {
    enable = mkEnableOption "enable wsl with my default";
  };

  config = mkIf config.modules.my.wsl.enable {
    wsl = {
      enable = true;
      wslConf.automount.root = "/mnt";
      defaultUser = "mar";
      startMenuLaunchers = true;
      wslConf.network.generateResolvConf = false;

      # Enable native Docker support
      # docker-native.enable = true;
      # Enable integration with Docker Desktop (needs to be installed)
      #docker-desktop.enable = true;
    };
    networking.nameservers = [ "1.1.1.1" ];
    # users.users.mar = { shell = pkgs.zsh; };
  };
}
