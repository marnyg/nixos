{ lib, config, ... }:
with lib;
{
  options.modules.my.kitty = {
    enable = mkOption { type = types.bool; default = false; };
    fontsize = mkOption { type = types.number; default = 12; };
  };

  config = mkIf config.modules.my.kitty.enable {

    #modules.my.nushell.enable = true;

    programs.kitty = {
      enable = true;
      #    font = "FiraCode nerd font";
      #font = pkgs.fira-code;
      #font = pkgs.noto-fonts;
      settings = {
        scrollback_lines = 10000;
        enable_audio_bell = false;
        update_check_interval = 0;
      };
      font = {
        # package = (pkgs.nerdfonts.override {
        #   fonts = [ "FiraCode" "DroidSansMono" "FiraMono" "JetBrainsMono" ];
        # });
        name = "Fira Code Nerd Font";
        size = config.modules.my.kitty.fontsize;
        #size = "6";
        #name= "Fira Mono Nerd Font";
        #name ="JetBrains Mono";
        #name= "Droid Sans Mono Nerd Font";
        #name= "Noto Nerd Font";
      };
    };
  };
}
