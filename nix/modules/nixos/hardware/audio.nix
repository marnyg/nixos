# Audio hardware profile
{ config, lib, ... }:

with lib;

{
  options.hardware.profiles.audio = {
    enable = mkEnableOption "audio support";

    backend = mkOption {
      type = types.enum [ "pipewire" "pulseaudio" "alsa" ];
      default = "pipewire";
      description = "Audio backend to use";
    };

    support32Bit = mkOption {
      type = types.bool;
      default = true;
      description = "Enable 32-bit application support (for Steam, Wine, etc.)";
    };
  };

  config = mkIf config.hardware.profiles.audio.enable (mkMerge [
    # Common audio configuration
    {
      security.rtkit.enable = mkDefault true;
    }

    # PipeWire configuration
    (mkIf (config.hardware.profiles.audio.backend == "pipewire") {
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = config.hardware.profiles.audio.support32Bit;
        pulse.enable = true;
        wireplumber.enable = true;

        # Optional: JACK compatibility
        jack.enable = mkDefault false;
      };

      # Disable PulseAudio since we're using PipeWire
      services.pulseaudio.enable = mkDefault false;
    })

    # PulseAudio configuration
    (mkIf (config.hardware.profiles.audio.backend == "pulseaudio") {
      services.pulseaudio = {
        enable = true;
        support32Bit = config.hardware.profiles.audio.support32Bit;

        # Optional: Better sound quality
        daemon.config = {
          default-sample-format = mkDefault "s24le";
          default-sample-rate = mkDefault 48000;
          alternate-sample-rate = mkDefault 44100;
        };
      };

      # Disable PipeWire since we're using PulseAudio
      services.pipewire.enable = false;
    })

    # ALSA only configuration
    (mkIf (config.hardware.profiles.audio.backend == "alsa") {
      sound.enable = true;
      services.pulseaudio.enable = mkDefault false;
      services.pipewire.enable = mkDefault false;
    })
  ]);
}
