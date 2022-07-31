{
  # home.file = {
  #    ".config/polybar/conf.ini" = {
  #      text= (builtins.readFile ./config.ini);
  #    };
  # };
  services.polybar = {
    enable = true;
    # configFile =  "./config.ini";
    extraConfig = (builtins.readFile ./config.ini);
    script = ''
      #for m in $(polybar --list-monitors | cut -d":" -f1); do
      monitors=(DVI-D-1 DVI-I-1)
      for m in $monitors ; do
          MONITOR=$m polybar --reload example &
      done
    '';
  };
}
