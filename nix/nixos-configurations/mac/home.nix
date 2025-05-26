{ pkgs, inputs, ... }:

{
  imports = [ inputs.agenix.homeManagerModules.default ];

  home.stateVersion = "23.05";
  home.homeDirectory = "/Users/mariusnygard";

  programs.ncspot.enable = true;

  myHmModules.sharedDefaults.enable = false;
  modules.zsh.enable = false;
  modules.fish.enable = true;
  modules.direnv.enable = true;
  modules.myPackages.enable = true;
  modules.cloneDefaultRepos.enable = false;
  modules.lf.enable = false;
  modules.tmux.enable = true;
  modules.firefox.enable = true;
  myModules.git.enable = true;
  modules.kitty.enable = true;

  myModules.secrets.enable = true;
  modules.ghostty.enable = true;
  modules.ghostty.fontsize = 14;
  #TODO: switch to nushell

  # modules.bspwm.enable = lse;
  # modules.hyperland.enable = false;
  # modules.newsboat.enable = false;
  # modules.polybar.enable = false;
  # modules.xmonad.enable = false;
  # modules.spotifyd.enable = false;
  # modules.other.enable = false;
  # modules.zellij.enable = false;
  # modules.autorandr.enable = false;
  # modules.dunst.enable = false;

  programs.yazi.enable = true;

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # programs.fzf.enable=true;

  programs.htop.enable = true;
  programs.htop.settings.show_program_path = true;

  home.packages = with pkgs; [
    coreutils
    curl
    wget
    slack
    teams-for-linux
    # outlook
    github-cli

    #m-cli # useful macOS CLI commands
  ];

}
