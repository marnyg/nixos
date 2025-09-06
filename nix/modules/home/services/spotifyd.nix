{ pkgs, lib, config, ... }:
with lib;
{
  options.modules.my.spotifyd = {
    enable = mkOption { type = types.bool; default = false; };
  };
  config = mkIf config.modules.my.spotifyd.enable
    {
      home.packages = [ pkgs.spotify-player ];
      services.spotifyd = (if pkgs.system != "aarch64-darwin" then {
        enable = true;
        # package = pkgs.spotifyd.override {
        #   withMpris = true;
        #   withPulseAudio = true;
        # };
        settings = {
          global = {
            username = "marnyg31.10";
            # backend = "alsa";
            # device = "default";
            # mixer = "PCM";
            # volume-controller = "alsa";
            # device_name = "spotifyd";
            # device_type = "speaker";
            bitrate = 96;
            cache_path = ".cache/spotifyd";
            volume-normalisation = true;
            normalisation-pregain = -10;
            # initial_volume = "50";
          };
        };
      } else { });
    };
}
