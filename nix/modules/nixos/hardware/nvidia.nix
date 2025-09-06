# NVIDIA GPU hardware profile
{ config, lib, ... }:

with lib;

{
  options.hardware.profiles.nvidia = {
    enable = mkEnableOption "NVIDIA GPU support";

    driver = mkOption {
      type = types.enum [ "stable" "beta" "production" ];
      default = "stable";
      description = "NVIDIA driver version to use";
    };

    powerManagement = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable NVIDIA power management (may cause issues with some GPUs)";
      };

      finegrained = mkOption {
        type = types.bool;
        default = false;
        description = "Enable fine-grained power management (for laptops)";
      };
    };
  };

  config = mkIf config.hardware.profiles.nvidia.enable {
    # Enable graphics drivers (same as old config)
    hardware.graphics = {
      enable = true;
      enable32Bit = true; # Support for 32-bit applications (Steam, Wine)
    };

    # NVIDIA specific configuration - CRITICAL: must load nvidia driver
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      # Modesetting is REQUIRED - same as old config
      modesetting.enable = true;

      powerManagement = {
        enable = config.hardware.profiles.nvidia.powerManagement.enable;
        finegrained = config.hardware.profiles.nvidia.powerManagement.finegrained;
      };

      # Use open-source kernel modules - matching old config exactly
      open = true; # Don't use mkDefault - this was true in working config

      # Enable NVIDIA settings menu
      nvidiaSettings = true;

      # Select driver package based on option
      package =
        let
          driverPkg = config.hardware.profiles.nvidia.driver;
        in
        if driverPkg == "stable" then
          config.boot.kernelPackages.nvidiaPackages.stable
        else if driverPkg == "beta" then
          config.boot.kernelPackages.nvidiaPackages.beta
        else
          config.boot.kernelPackages.nvidiaPackages.production;
    };

    # Environment variables for NVIDIA support
    environment.sessionVariables = {
      # For Wayland compatibility
      WLR_NO_HARDWARE_CURSORS = "1";
      LIBVA_DRIVER_NAME = "nvidia";
      XDG_SESSION_TYPE = "wayland";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      # For better Vulkan support
      VK_DRIVER_FILES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";
    };
  };
}
