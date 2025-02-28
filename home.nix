{ pkgs, ... }:

{
  home.stateVersion = "23.05";

  # imports = [ inputs.agenix.homeManagerModules.default ];

  programs.ncspot.enable = true;

  myHmModules.sharedDefaults.enable = false;
  modules.zsh.enable = false;
  modules.direnv.enable = true;
  modules.myPackages.enable = true;
  modules.cloneDefaultRepos.enable = false;
  modules.lf.enable = true;
  modules.tmux.enable = true;
  modules.firefox.enable = true;
  myModules.git.enable = true;
  modules.kitty.enable = true;

  #TODO: fix below
  # myModules.secrets.enable = false;
  # modules.ghostty.enable = false;
  #TODO: switch to nushell

  # modules.bspwm.enable = false;
  # modules.hyperland.enable = false;
  # modules.newsboat.enable = false;
  # modules.polybar.enable = false;
  # modules.xmonad.enable = false;
  # modules.spotifyd.enable = false;
  # modules.other.enable = false;
  # modules.zellij.enable = false;
  # modules.autorandr.enable = false;
  # modules.dunst.enable = false;
  targets.darwin.keybindings = {
    "^h" = "nil";
  };

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

