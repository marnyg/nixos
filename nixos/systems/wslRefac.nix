{ pkgs, inputs, config, ... }:
let
  # TODO:move this out into own users file
  defaultHMConfig ={config,...}: {
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
      enable = true;
      gitDir = "${config.home.homeDirectory}/git";
      repoInfo = {
        sendra = {
          key = "${config.home.homeDirectory}/.ssh/id_rsa";
          repos = [
            "git@gitlab.com:prores/sendra/devops.git"
            "git@gitlab.com:prores/fieldview/field-view-api.git"
            "git@gitlab.com:prores/sendra/keycloak-image.git"
            "git@gitlab.com:prores/sendra/sendra-cli.git"
            "git@gitlab.com:prores/sendra/sendra.git"
            "git@gitlab.com:prores/sendra/sendra-compose.git"
            "git@gitlab.com:prores/sendra/sendra-engine.git"
            "git@gitlab.com:prores/sendra/sendra-importer.git"
            "git@gitlab.com:prores/sendra/sendra-integrationtests.git"
            "git@gitlab.com:prores/sendra/sendra-keycloak-theme.git"
            "git@gitlab.com:prores/sendra/sendra-settings.git"
            "git@gitlab.com:prores/sendra/sendra-sona.git"
            "git@gitlab.com:prores/sendra/sendra-userservice.git"
            "git@gitlab.com:prores/sendra/sendra-web.git"
            "git@gitlab.com:prores/sendra/sendra-units.git"
            "git@gitlab.com:prores/sendra/sendra-exporter.git"
            "git@gitlab.com:prores/sendra/sendra-database.git"
            "git@gitlab.com:prores/sendra/sendra-contract.git"
            "git@gitlab.com:prores/sendra/sendra-assets.git"
            "git@gitlab.com:prores/sendra/sendra-release-tools.git"
          ];
        };
        hiplog = {
          key = "${config.home.homeDirectory}/.ssh/id_ed25519";
          repos = [
            "git@gitlab-well:wellstarter/audit-trail.git"
            "git@gitlab-well:wellstarter/hiplog/compose.git"
            "git@gitlab-well:wellstarter/hiplog/data-interpreter.git"
            "git@gitlab-well:wellstarter/hiplog/devops.git"
            "git@gitlab-well:wellstarter/hiplog/filestore.git"
            "git@gitlab-well:wellstarter/hiplog/filestore-client.git"
            "git@gitlab-well:wellstarter/hiplog/forward-modeling.git"
            "git@gitlab-well:wellstarter/hiplog-fe-nuxt3.git"
            "git@gitlab-well:wellstarter/hiplog-matlab.git"
            "git@gitlab-well:wellstarter/matlab-runner.git"
            "git@gitlab-well:wellstarter/matlab-runtime.git"
            "git@gitlab-well:wellstarter/hiplog/pdf-converter.git"
            "git@gitlab-well:wellstarter/hiplog/units.git"
            "git@gitlab-well:wellstarter/hiplog/user-service.git"
            "git@gitlab-well:wellstarter/hiplog/wells-backend.git"
          ];
        };
      };
    };
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
  virtualisation.docker.enable = true;

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
