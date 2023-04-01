{ pkgs, lib, config, ... }:
with lib;
{
  options.modules.syncthing = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.syncthing.enable
    {
      services.syncthing = {
        enable = true;
        overrideDevices =
          true; # overrides any devices added or deleted through the WebUI
        overrideFolders =
          true; # overrides any folders added or deleted through the WebUI
        user = "mar";
        #group   = "wheel";
        dataDir = "/home/mar/";
        devices = {
          "aws" = {
            id = "GQDUKFK-HQRZYTR-WUDIIAE-MVQOOSY-DALLCEE-DTJMVTZ-DGPKS7P-VVQVKAE";
          };
          "workPc" = {
            id = "IKII2EG-O2YCQ64-6RI2ADV-VHXWB7P-XKNN4HH-5H3PJG5-B7AV44K-LTWGCQG";
          };
        };
        folders = {
          "nextcloud" = {
            # Name of folder in Syncthing, also the folder ID
            path = "/home/mar/mnt/nextcloud"; # Which folder to add to Syncthing
            devices = [ "aws" "workPc" ]; # Which devices to share the folder with
          };
          #  "Example" = {
          #    path = "/home/myusername/Example";
          #    devices = [ "device1" ];
          #    ignorePerms = false;     # By default, Syncthing doesn't sync file permissions. This line enables it for this folder.
          #  };
        };
      };

      # Open ports in the firewall.
      networking.firewall.allowedTCPPorts = [ 8384 22000 ];
      networking.firewall.allowedUDPPorts = [ 8384 22000 21027 ];
    };
}
