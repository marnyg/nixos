{ pkgs, lib, config, ... }:
with lib;
{
  options.modules.polybar = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.polybar.enable {
    services.polybar = {
      enable = true;
      extraConfig = (builtins.readFile ./config.ini);
      script = with pkgs; ''
        for m in $(polybar --list-monitors | ${coreutils}/bin/cut -d":" -f1); do
          MONITOR=$m polybar --reload example &
        done
      '';
    };
  };
}
