{ pkgs, inputs, config, ... }:
let
  # TODO:move this out into own users file
  defaultHMConfig = {
    myHmModules.sharedDefaults.enable = true;

    modules.zsh.enable = true;
    modules.direnv.enable = true;
    modules.zellij.enable = false;
    modules.tmux.enable = true;
    modules.fzf.enable = true;
    modules.firefox.enable = true;
    modules.autorandr.enable = false;
    modules.bspwm.enable = false;
    modules.dunst.enable = false;
    modules.kitty.enable = true;
    myModules.git.enable = true;
    modules.newsboat.enable = false;
    modules.polybar.enable = false;
    modules.xmonad.enable = false;
    modules.spotifyd.enable = false;
    modules.other.enable = false;
    modules.myPackages.enable = true;
    modules.cloneDefaultRepos.enable = true;
    modules.lf.enable = true;
    programs.yazi.enable = true;
  };
in
{
  ##
  ## system modules config
  ##
  modules.myNvim.enable = true; # TODO: should be managed by homemanger
  myModules.wsl.enable = true;
  myModules.defaults.enable = true;

  # for vscode server
  programs.nix-ld.enable = true;

  # yubikey
  services.udev.packages = [ pkgs.yubikey-personalization ];
  security.pam.yubico = {
    enable = true;
    #debug = true;
    mode = "challenge-response";
  };
  virtualisation.docker.enable =true;

  ## 
  ## users and homemanager modules config
  ## 
  myModules.createUsers = {
    enable = true;
    users = [
      # TODO: move this out into own users file
      { name = "mar"; homeManager = true; homeManagerConf = defaultHMConfig; }
      { name = "test"; homeManager = true; }
      { name = "notHM"; homeManager = false; }
    ];
    personalHomeManagerModules = [{ imports = inputs.my-modules.hmModulesModules.x86_64-linux; }];
  };
}
