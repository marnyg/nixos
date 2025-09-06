# WSL system profile
{ lib, config, pkgs, ... }:
with lib;
{
  options.modules.my.wsl = {
    enable = mkEnableOption "enable wsl with my default";
  };

  config = mkIf config.modules.my.wsl.enable {
    # Core modules
    modules.my = {
      defaults.enable = true;
      secrets.enable = true;
      nixSettings.enable = true;
    };

    # WSL-specific configuration
    wsl = {
      enable = true;
      wslConf.automount.root = "/mnt";
      defaultUser = "mar";
      startMenuLaunchers = true;
      wslConf.network.generateResolvConf = false;
      # docker-native.enable = true;
      # docker-desktop.enable = true;
    };

    networking.nameservers = [ "1.1.1.1" ];

    # SSH configuration
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };

    # For VSCode server
    programs.nix-ld.enable = true;

    # Yubikey support
    services.udev.packages = [ pkgs.yubikey-personalization ];
    security.pam.yubico = {
      enable = true;
      mode = "challenge-response";
    };

    # Container support
    virtualisation = {
      containers.enable = true;
      podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled = true;
      };
    };
  };
}
