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
    # Enable graphics drivers
    hardware.graphics = {
      enable = true;
      enable32Bit = true; # Support for 32-bit applications (Steam, Wine)
    };

    # NVIDIA specific configuration
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      modesetting.enable = true; # Required for Wayland compositors

      powerManagement = {
        enable = config.hardware.profiles.nvidia.powerManagement.enable;
        finegrained = config.hardware.profiles.nvidia.powerManagement.finegrained;
      };

      # Use open-source kernel modules where possible
      open = mkDefault true;

      # GUI for NVIDIA settings
      nvidiaSettings = mkDefault true;

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

    # Environment variables for better NVIDIA support
    environment.sessionVariables = {
      # For Wayland compatibility
      WLR_NO_HARDWARE_CURSORS = mkDefault "1";
      # For better Vulkan support
      VK_DRIVER_FILES = mkDefault "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";
    };
  };
}
