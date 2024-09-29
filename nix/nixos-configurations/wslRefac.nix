{ pkgs, config, ... }:
let
  # TODO:move this out into own users file
  defaultHMConfig = { config, ... }: {
    #imports = builtins.attrValues config.myHomemanagerModules.modules;
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
    modules.services.cloneWorkRepos = {
      enable = false;
      gitDir = "${config.home.homeDirectory}/git";
      repoInfo = {
        sendra = {
          key = "${config.home.homeDirectory}/.ssh/id_rsa";
          repos = [
          ];
        };
        hiplog = {
          key = "${config.home.homeDirectory}/.ssh/id_ed25519";
          repos = [
          ];
        };
      };
    };
    modules.lf.enable = true;
    programs.yazi.enable = true;
  };
in
{
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  users.users.mar.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBR+GCws2rQ30VOYAvIiWtbRrHfveej4H2L+/s28JTCG trash@win"
  ];

  ##
  ## system modules config
  ##
  # myModules.myNvim.enable = true; # TODO: should be managed by homemanger
  myModules.myNixvim.enable = true;

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
  virtualisation.docker.enable = true;
  users.groups.docker.members = [ "mar" ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "python-2.7.18.7"
    "nix-2.16.2"
  ];
  nix.settings.trusted-users = [ "root" "mar" ];

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
  };
}
