{ pkgs, inputs, config, ... }:
let
  defaultHMConfig = {

    myHmModules.sharedDefaults.enable = true;

    modules.zsh.enable = true;
    modules.direnv.enable = true;
    modules.zellij.enable = true;
    modules.tmux.enable = true;
    modules.fzf.enable = true;
    modules.firefox.enable = true;
    modules.autorandr.enable = false;
    modules.bspwm.enable = false;
    modules.dunst.enable = true;
    modules.kitty.enable = true;
    myModules.git.enable = true;
    modules.newsboat.enable = true;
    modules.polybar.enable = false;
    modules.xmonad.enable = false;
    modules.spotifyd.enable = false;
    modules.other.enable = true;
    modules.myPackages.enable = true;
    modules.cloneDefaultRepos.enable = true;
  };
in
{
  modules.myNvim.enable = true; # TODO: should be managed by homemanger
  myModules.wsl.enable = true;

  myModules.defaults.enable = true;

  ## 
  ## users and homemanager
  ## 
  myModules.createUsers = {
    enable = true;
    users = [
      { name = "mar"; homeManager = true; }
      { name = "test"; homeManager = true; }
      { name = "notHM"; homeManager = false; }
    ];
    personalHomeManagerModules = [{ imports = inputs.my-modules.hmModulesModules.x86_64-linux; }];
  };
}
