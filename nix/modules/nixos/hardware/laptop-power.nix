# Laptop power management hardware profile
{ config, lib, ... }:

with lib;

{
  options.hardware.profiles.laptopPower = {
    enable = mkEnableOption "laptop power management";

    cpuFreqGovernor = mkOption {
      type = types.enum [ "performance" "powersave" "ondemand" "conservative" "schedutil" ];
      default = "powersave";
      description = "CPU frequency scaling governor";
    };

    batteryThresholds = {
      start = mkOption {
        type = types.int;
        default = 75;
        description = "Battery charge start threshold (%)";
      };

      stop = mkOption {
        type = types.int;
        default = 80;
        description = "Battery charge stop threshold (%)";
      };
    };

    enableTlp = mkOption {
      type = types.bool;
      default = true;
      description = "Enable TLP for advanced power management";
    };
  };

  config = mkIf config.hardware.profiles.laptopPower.enable {
    # Basic power management
    powerManagement = {
      enable = true;
      cpuFreqGovernor = config.hardware.profiles.laptopPower.cpuFreqGovernor;
    };

    # Thermal management
    services.thermald.enable = mkDefault true;

    # TLP for advanced power management
    services.tlp = mkIf config.hardware.profiles.laptopPower.enableTlp {
      enable = true;
      settings = {
        # CPU settings
        CPU_SCALING_GOVERNOR_ON_AC = mkForce "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = mkForce "powersave";

        CPU_BOOST_ON_AC = mkDefault 1;
        CPU_BOOST_ON_BAT = mkDefault 0;

        # Turbo boost settings
        CPU_HWP_DYN_BOOST_ON_AC = mkDefault 1;
        CPU_HWP_DYN_BOOST_ON_BAT = mkDefault 0;

        # Battery charge thresholds (if supported by hardware)
        START_CHARGE_THRESH_BAT0 = config.hardware.profiles.laptopPower.batteryThresholds.start;
        STOP_CHARGE_THRESH_BAT0 = config.hardware.profiles.laptopPower.batteryThresholds.stop;

        # Disk power management
        DISK_DEVICES = mkDefault "nvme0n1 sda";
        DISK_APM_LEVEL_ON_AC = mkDefault "254 254";
        DISK_APM_LEVEL_ON_BAT = mkDefault "128 128";

        # USB autosuspend
        USB_AUTOSUSPEND = mkDefault 1;
        USB_EXCLUDE_AUDIO = mkDefault 1;
        USB_EXCLUDE_BTUSB = mkDefault 0;
        USB_EXCLUDE_PHONE = mkDefault 0;
        USB_EXCLUDE_PRINTER = mkDefault 1;
        USB_EXCLUDE_WWAN = mkDefault 0;

        # PCIe power management
        PCIE_ASPM_ON_AC = mkDefault "default";
        PCIE_ASPM_ON_BAT = mkDefault "powersupersave";

        # Graphics card power management
        RADEON_DPM_PERF_LEVEL_ON_AC = mkDefault "auto";
        RADEON_DPM_PERF_LEVEL_ON_BAT = mkDefault "low";

        # WiFi power management
        WIFI_PWR_ON_AC = mkDefault "off";
        WIFI_PWR_ON_BAT = mkDefault "on";

        # Audio power management
        SOUND_POWER_SAVE_ON_AC = mkDefault 0;
        SOUND_POWER_SAVE_ON_BAT = mkDefault 1;
        SOUND_POWER_SAVE_CONTROLLER = mkDefault "Y";
      };
    };

    # ACPI support for laptop-specific features
    services.acpid.enable = mkDefault true;

    # Enable backlight control
    programs.light.enable = mkDefault true;

    # Battery optimization for acpilight
    hardware.acpilight.enable = mkDefault true;

    # Suspend and hibernation settings
    services.logind = {
      settings = {
        Login = {
          HandleLidSwitch = mkDefault "suspend";
          HandleLidSwitchExternalPower = mkDefault "ignore";
          HandlePowerKey = mkDefault "suspend";
          IdleAction = mkDefault "suspend";
          IdleActionSec = mkDefault "15min";
        };
      };
    };

    # Power profiles daemon (alternative to TLP, don't enable both)
    services.power-profiles-daemon.enable = mkIf (!config.hardware.profiles.laptopPower.enableTlp) true;

    # UPower for battery status
    services.upower = {
      enable = mkDefault true;
      percentageLow = mkDefault 10;
      percentageCritical = mkDefault 5;
      percentageAction = mkDefault 3;
      criticalPowerAction = mkDefault "Hibernate";
    };
  };
}
