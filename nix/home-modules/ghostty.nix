{ lib, config, pkgs, ... }:
with lib;
{
  options.modules.ghostty = {
    enable = mkOption { type = types.bool; default = false; };
    fontsize = mkOption { type = types.number; default = 12; };
  };

  config = mkIf config.modules.ghostty.enable {
    programs.nushell = {
      enable = true;

      configFile.text = ''
        $env.config.edit_mode = 'vi'
        $env.config.show_banner = false
        $env.ANTHROPIC_API_KEY = open "/run/agenix/claudeToken"


        def gcm [...message: string] {
            git commit -m ($message | str join " ")
        }

        alias c = clear;
        alias chx = chmod +x;
        alias v = nvim;
        alias mkdir = mkdir -v;
        alias rm = rm -rifv;
        alias mv = mv -iv;
        alias cp = cp -riv;
        alias cdn = cd ~/git/nixos;
        alias cat = ${pkgs.bat}/bin/bat --paging=never --style=plain;
        alias tree = ${pkgs.eza}/bin/eza --tree --icons;
        alias du = ${pkgs.du-dust}/bin/dust;
        alias dua = ${pkgs.dua}/bin/dua;
        alias df = ${pkgs.duf}/bin/duf;
        alias lf = ${pkgs.yazi}/bin/yazi;

        alias g = git
        alias gm = git merge
        alias gmv = git mv
        alias grm = git rm
        alias gs = git status
        alias gss = git status -s
        alias gl = git pull
        alias gc = git commit
        alias ga = git add
        alias gai = git add -i
        alias gi = ${pkgs.lazygit}/bin/lazygit
        alias gap = git add -p
        alias gaa = git add -A
        alias gpr = git pull --rebase
        #alias gfrb = git fetch; git rebase
        alias gp = git push
        alias gcount = git shortlog -sn
        alias gco = git checkout
        alias gsl = git shortlog -sn
        alias gwc = git whatchanged
        alias gcaa = git commit -a --amend -C HEAD
        alias gpm = git push origin main
        alias gd = git diff
        alias gb = git branch
        alias gt = git tag
        #alias gaugcm = git add -u; gcm
        #alias gfp = git commit --amend --no-edit; git push --force-with-lease
      '';

    };

    programs.starship.enable = true;
    programs.starship.enableNushellIntegration = true;


    programs.ghostty = {
      enable = true;

      settings = {
        theme = "catppuccin-mocha";
        font-size = 10;
        # shell-integration = "none";
        # title = " ";
        window-decoration = false;
        confirm-close-surface = false;
      };
      themes = {
        catppuccin-mocha = {
          background = "1e1e2e";
          cursor-color = "f5e0dc";
          foreground = "cdd6f4";
          palette = [
            "0=#45475a"
            "1=#f38ba8"
            "2=#a6e3a1"
            "3=#f9e2af"
            "4=#89b4fa"
            "5=#f5c2e7"
            "6=#94e2d5"
            "7=#bac2de"
            "8=#585b70"
            "9=#f38ba8"
            "10=#a6e3a1"
            "11=#f9e2af"
            "12=#89b4fa"
            "13=#f5c2e7"
            "14=#94e2d5"
            "15=#a6adc8"
          ];
          selection-background = "353749";
          selection-foreground = "cdd6f4";
        };

      };

      # font = {
      #   name = "Fira Code Nerd Font";
      #   size = config.modules.ghostty.fontsize;
      #   #size = "6";
      #   #name= "Fira Mono Nerd Font";
      #   #name ="JetBrains Mono";
      #   #name= "Droid Sans Mono Nerd Font";
      #   #name= "Noto Nerd Font";
      # };
    };
  };
}
