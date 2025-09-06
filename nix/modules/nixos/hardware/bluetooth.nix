# Bluetooth hardware profile
{ config, lib, pkgs, ... }:

with lib;

{
  options.hardware.profiles.bluetooth = {
    enable = mkEnableOption "Bluetooth support";

    powerOnBoot = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to power on Bluetooth on boot";
    };

    hsphfpd = mkOption {
      type = types.bool;
      default = false;
      description = "Enable hsphfpd for better headset support";
    };
  };

  config = mkIf config.hardware.profiles.bluetooth.enable {
    # Enable Bluetooth hardware support
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = config.hardware.profiles.bluetooth.powerOnBoot;

      # Better codec support for audio devices
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = mkDefault true; # Enable experimental features for better compatibility
        };
      };

      # Optional: disable specific plugins that may cause issues
      disabledPlugins = mkDefault [ ];
    };

    # Bluetooth manager GUI
    services.blueman.enable = mkDefault true;

    # Optional: hsphfpd for better Bluetooth headset support
    services.pipewire.wireplumber.configPackages = mkIf config.hardware.profiles.bluetooth.hsphfpd [
      (pkgs.writeTextDir "share/wireplumber/bluetooth.lua.d/51-bluez-config.lua" ''
        bluez_monitor.properties = {
          ["bluez5.enable-sbc-xq"] = true,
          ["bluez5.enable-msbc"] = true,
          ["bluez5.enable-hw-volume"] = true,
          ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
        }
      '')
    ];

    # Ensure the Bluetooth service can be managed by users
    systemd.services.bluetooth.serviceConfig.ExecStart = mkIf config.hardware.profiles.bluetooth.hsphfpd [
      ""
      "${pkgs.bluez}/libexec/bluetooth/bluetoothd -f /etc/bluetooth/main.conf --noplugin=sap"
    ];
  };
}
