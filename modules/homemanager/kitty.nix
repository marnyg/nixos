{ pkgs, lib, config, ... }:
with lib;
{
  options.modules.kitty = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.kitty.enable {
    programs.kitty = {
      enable = true;
      #    font = "FiraCode nerd font";
      #font = pkgs.fira-code;
      #font = pkgs.noto-fonts;
      font = {
        package = (pkgs.nerdfonts.override {
          fonts = [ "FiraCode" "DroidSansMono" "FiraMono" "JetBrainsMono" ];
        });
        name = "Fira Code Nerd Font";
        #name= "Fira Mono Nerd Font";
        #name ="JetBrains Mono";
        #name= "Droid Sans Mono Nerd Font";
        #name= "Noto Nerd Font";
      };
    };
  };
}
