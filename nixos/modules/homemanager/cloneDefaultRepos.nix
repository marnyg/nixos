{ pkgs, lib, config, ... }:
with lib;
{
  options.modules.cloneDefaultRepos = {
    enable = mkOption { type = types.bool; default = false; };
  };
  config = mkIf config.modules.cloneDefaultRepos.enable
    {
      programs.ssh = {
        enable = true;
        extraConfig = ''
          Host gitlab-sendra
            HostName gitlab.com
            User git
            IdentityFile ~/.ssh/id_rsa
            IdentitiesOnly yes

          Host gitlab-well
            HostName gitlab.com
            User git
            IdentityFile ~/.ssh/id_ed25519
            IdentitiesOnly yes
        '';
      };
      systemd.user.services.copySshFromHost =
        {
          Install.WantedBy = [ "default.target" ]; # starts after login
          Unit.After = [ "network-online.target" ]; # starts after login
          Unit.Description = "Example description";
          Service.ExecStart = "/bin/sh ${pkgs.writeScript "copySshKey.sh" ''
          ${pkgs.coreutils}/bin/cp -n /mnt/c/Users/trash/.ssh/* /home/mar/.ssh/
          ${pkgs.findutils}/bin/find /home/mar/.ssh/* -type f -print0 | ${pkgs.findutils}/bin/xargs -0 ${pkgs.coreutils}/bin/chmod 0600 
          ''
          }";
          Service.Type = "oneshot";
        };
      systemd.user.services.cloneDefaultRepos =
        {
          #Install.WantedBy = [ "multi-user.target" ]; # starts after login
          Install.WantedBy = [ "default.target" ]; # starts after login
          Unit.After = [ "network-online.target" ]; # starts after login
          Unit.Description = "Example description";
          Service.ExecStart = "/bin/sh ${pkgs.writeScript "cloneMyStuff.sh" ''
            ${pkgs.openssh}/bin/ssh-keygen -F github.com || ${pkgs.openssh}/bin/ssh-keyscan github.com >> ~/.ssh/known_hosts
            ${pkgs.git}/bin/git clone git@github.com:marnyg/nixos.git /home/mar/git/nixos
          ''
          }";
          Service.Type = "oneshot";
        };
      systemd.user.services.cloneWorkRepos = {
        #Install.WantedBy = [ "multi-user.target" ]; # starts after login
        Install.WantedBy = [ "default.target" ]; # starts after login
        Unit.After = [ "copySshFromHost" ];
        Unit.Description = "Example description";
        Service.ExecStart = "/bin/sh ${pkgs.writeScript "cloneWorkStuff.sh" ''
          ${pkgs.openssh}/bin/ssh-keygen -F gitlab.com || ${pkgs.openssh}/bin/ssh-keyscan gitlab.com >> ~/.ssh/known_hosts
          #sendra
          mkdir /home/mar/git/sendra
          cd /home/mar/git/sendra
          ${pkgs.git}/bin/git clone git@gitlab.com:prores/sendra/devops.git
          ${pkgs.git}/bin/git clone git@gitlab.com:prores/fieldview/field-view-api.git
          ${pkgs.git}/bin/git clone git@gitlab.com:prores/sendra/keycloak-image.git
          ${pkgs.git}/bin/git clone git@gitlab.com:prores/sendra/sendra-cli.git
          ${pkgs.git}/bin/git clone git@gitlab.com:prores/sendra/sendra-compose.git
          ${pkgs.git}/bin/git clone git@gitlab.com:prores/sendra/sendra-engine.git
          ${pkgs.git}/bin/git clone git@gitlab.com:prores/sendra/sendra-importer.git
          ${pkgs.git}/bin/git clone git@gitlab.com:prores/sendra/sendra-integrationtests.git
          ${pkgs.git}/bin/git clone git@gitlab.com:prores/sendra/sendra-keycloak-theme.git
          ${pkgs.git}/bin/git clone git@gitlab.com:prores/sendra/sendra-settings.git
          ${pkgs.git}/bin/git clone git@gitlab.com:prores/sendra/sendra-sona.git
          ${pkgs.git}/bin/git clone git@gitlab.com:prores/sendra/sendra-userservice.git
          ${pkgs.git}/bin/git clone git@gitlab.com:prores/sendra/sendra-web.git
          ${pkgs.git}/bin/git clone git@gitlab.com:prores/sendra/sendra-units.git
          ${pkgs.git}/bin/git clone git@gitlab.com:prores/sendra/sendra-exporter.git
          ${pkgs.git}/bin/git clone git@gitlab.com:prores/sendra/sendra-database.git
          ${pkgs.git}/bin/git clone git@gitlab.com:prores/sendra/sendra-contract.git
          ${pkgs.git}/bin/git clone git@gitlab.com:prores/sendra/sendra-assets.git
          #wellstarter
          mkdir /home/mar/git/hiplog
          cd /home/mar/git/hiplog
          ${pkgs.git}/bin/git clone git@gitlab-well:wellstarter/audit-trail.git
          ${pkgs.git}/bin/git clone git@gitlab-well:wellstarter/hiplog/compose.git
          ${pkgs.git}/bin/git clone git@gitlab-well:wellstarter/hiplog/data-interpreter.git
          ${pkgs.git}/bin/git clone git@gitlab-well:wellstarter/hiplog/devops.git
          ${pkgs.git}/bin/git clone git@gitlab-well:wellstarter/hiplog/filestore.git
          ${pkgs.git}/bin/git clone git@gitlab-well:wellstarter/hiplog/filestore-client.git
          ${pkgs.git}/bin/git clone git@gitlab-well:wellstarter/hiplog/forward-modeling.git
          ${pkgs.git}/bin/git clone git@gitlab-well:wellstarter/hiplog-fe-nuxt3.git
          ${pkgs.git}/bin/git clone git@gitlab-well:wellstarter/hiplog-matlab.git
          ${pkgs.git}/bin/git clone git@gitlab-well:wellstarter/matlab-runner.git
          ${pkgs.git}/bin/git clone git@gitlab-well:wellstarter/matlab-runtime.git
          ${pkgs.git}/bin/git clone git@gitlab-well:wellstarter/hiplog/pdf-converter.git
          ${pkgs.git}/bin/git clone git@gitlab-well:wellstarter/hiplog/units.git
          ${pkgs.git}/bin/git clone git@gitlab-well:wellstarter/hiplog/user-service.git
          ${pkgs.git}/bin/git clone git@gitlab-well:wellstarter/hiplog/wells-backend.git
        ''
        }";
        Service.Type = "oneshot";
      };


    };
}
