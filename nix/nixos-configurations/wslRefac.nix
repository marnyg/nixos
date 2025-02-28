{ inputs, pkgs, config, ... }:
let
  # TODO:move this out into own users file
  defaultHMConfig = { config, ... }: {
    #imports = builtins.attrValues config.myHomemanagerModules.modules;
    imports = [ inputs.agenix.homeManagerModules.default ];
    myModules.secrets.enable = true;

    myHmModules.sharedDefaults.enable = true;

    myServices.s3fs.enable = true;
    myServices.s3fs.keyId = "";
    myServices.s3fs.accessKey = "";

    modules.zsh.enable = true;
    modules.direnv.enable = true;
    modules.zellij.enable = false;
    modules.tmux.enable = true;
    #modules.fzf.enable = false;
    modules.firefox.enable = true;
    modules.autorandr.enable = false;
    modules.bspwm.enable = false;
    modules.dunst.enable = false;
    modules.kitty.enable = false;
    modules.ghostty.enable = true;
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
  imports = [ inputs.agenix.nixosModules.age ];
  age.secrets.openrouterToken.file = ../home-modules/secrets/claudeToken.age;
  age.secrets.openrouterToken.owner = "mar";
  age.secrets.claudeToken.file = ../home-modules/secrets/claudeToken.age;
  age.secrets.claudeToken.owner = "mar";
  age.identityPaths = [ "/home/mar/.ssh/id_ed25519" ];
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
  # virtualisation.docker.enable = true;
  # users.groups.docker.members = [ "mar" ];
  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };


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
      # { name = "test"; homeManager = true; }
      { name = "notHM"; homeManager = false; }
    ];
  };
}
