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
  modules.tmux.enable = true;
  modules.firefox.enable = true;
  myModules.git.enable = true;
  modules.kitty.enable = true;
  #modules.qutebrowser.enable = true;

  myModules.secrets.enable = true;
  modules.ghostty.enable = true;
  modules.ghostty.fontsize = 14;

  programs.yazi.enable = true;

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # programs.fzf.enable=true;

  programs.htop.enable = true;
  programs.htop.settings.show_program_path = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  home.packages = with pkgs; [
    coreutils
    curl
    wget
    slack
    teams-for-linux
    # outlook
    #    github-cli

    #m-cli # useful macOS CLI commands
  ];

}
