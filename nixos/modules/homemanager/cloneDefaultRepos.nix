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
          #Install.WantedBy = [ "multi-user.target" ]; # starts after login
          Unit.After = [ "multi-user.target" ]; # starts after login
          Unit.Description = "Example description";
          Service.ExecStart = "${pkgs.coreutils}/bin/cp /mnt/c/Users/trash/.ssh/id* /home/mar/.ssh/ && chmod 0600 /home/mar/.ssh/*";
          Service.Type = "oneshot";
        };
      systemd.user.services.cloneDefaultRepos =
        {
          #Install.WantedBy = [ "multi-user.target" ]; # starts after login
          Unit.After = [ "multi-user.target" ]; # starts after login
          Unit.Description = "Example description";
          Service.ExecStart = "${pkgs.git}/bin/git clone https://github.com/marnyg/nixos /home/mar/git/nixos";
          Service.Type = "oneshot";
        };
      systemd.user.services.cloneWorkRepos = {
        #Install.WantedBy = [ "multi-user.target" ]; # starts after login
        Unit.After = [ "multi-user.target" "copySshFromHost" ];
        Unit.Description = "Example description";
        Service.ExecStart = "${pkgs.writeScript "cloneWorkStuff.sh" ''
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
