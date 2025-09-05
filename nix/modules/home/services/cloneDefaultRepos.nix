{ pkgs, lib, config, ... }:
with lib;
let

  envrcString = ''
    #use flake

    export BW_SESSION="$(get_bw_token)"

    export GITLAB_AUTH_TOKEN="$(get_secret gitlab-token password)"
    GITLAB_NUGET_WELLSTARTER_USER="$(get_secret gitlab-nuget-wellstarter username)"
    GITLAB_NUGET_WELLSTARTER_PASSWORD="$(get_secret gitlab-nuget-wellstarter password)"
    GITLAB_NUGET_PRORES_USER="$(get_secret gitlab-nuget-prores username)"
    GITLAB_NUGET_PRORES_PASSWORD="$(get_secret gitlab-nuget-prores password)"

    export NUGET_CONFIG_DIR=$(mktemp -d)
    export NUGET_CONFIG_FILE="$NUGET_CONFIG_DIR/nuget.config"
    dotnet new nugetconfig  --output $NUGET_CONFIG_DIR

    add_nuget_source "https://gitlab.com/api/v4/groups/5555215/-/packages/nuget/index.json" "Wellstarter" $GITLAB_NUGET_WELLSTARTER_USER $GITLAB_NUGET_WELLSTARTER_PASSWORD
    add_nuget_source "https://gitlab.com/api/v4/projects/42002329/packages/nuget/index.json" "Prores" $GITLAB_NUGET_PRORES_USER $GITLAB_NUGET_PRORES_PASSWORD
  '';

in
{
  options.modules.cloneDefaultRepos = {
    enable = mkOption { type = types.bool; default = false; };
  };
  config = mkIf config.modules.cloneDefaultRepos.enable
    {
      home.file.".ssh/.envrc".text = ''
        # SSH key management via Bitwarden
        export BW_SESSION=$(${pkgs.bitwarden-cli}/bin/bw login --raw)
        ${pkgs.bitwarden-cli}/bin/bw get notes prores-gitlab-ssh.priv > /home/mar/.ssh/id_rsa
        ${pkgs.bitwarden-cli}/bin/bw get notes wellstarter-gitlab-ssh.priv > /home/mar/.ssh/id_ed25519
        ${pkgs.bitwarden-cli}/bin/bw get notes personal-github-ssh.priv > /home/mar/.ssh/githubmarnyg

        ${pkgs.findutils}/bin/find /home/mar/.ssh/* -type f -print0 | ${pkgs.findutils}/bin/xargs -0 ${pkgs.coreutils}/bin/chmod 0600 

        ${pkgs.openssh}/bin/ssh-keygen -y -f /home/mar/.ssh/id_ed25519 > id_ed25519.pub
        ${pkgs.openssh}/bin/ssh-keygen -y -f /home/mar/.ssh/id_rsa > id_rsa.pub
        ${pkgs.openssh}/bin/ssh-keygen -y -f /home/mar/.ssh/githubmarnyg > githubmarnyg.pub

        if [[ -s ${config.home.homeDirectory}/.ssh/id_rsa ]] &&  [[  -s ${config.home.homeDirectory}/.ssh/id_ed25519 ]]; then
            systemctl start --user --no-block cloneWorkRepos.service
        fi
        if [[ -s ${config.home.homeDirectory}/.ssh/githubmarnyg ]]; then
            systemctl start --user --no-block cloneDefaultRepos.service
        fi
      '';

      systemd.user.services.cloneDefaultRepos =
        {
          #Install.WantedBy = [ "multi-user.target" ]; # starts after login
          Install.WantedBy = [ "default.target" ]; # starts after login
          Unit.After = [ "network-online.target" ]; # starts after login
          Unit.Description = "Example description";
          Unit.ConditionFileNotEmpty = [ "/home/mar/.ssh/githubmarnyg" ];
          Service.ExecStart = "/bin/sh ${pkgs.writeScript "cloneMyStuff.sh" ''
            ${pkgs.openssh}/bin/ssh-keygen -F github.com || ${pkgs.openssh}/bin/ssh-keyscan github.com >> ~/.ssh/known_hosts
            export GIT_SSH_COMMAND="${pkgs.openssh}/bin/ssh -i /home/mar/.ssh/githubmarnyg"
            ${pkgs.coreutils}/bin/mkdir /home/mar/git
            ${pkgs.git}/bin/git clone git@github.com:marnyg/nixos.git /home/mar/git/nixos
            ${pkgs.git}/bin/git clone git@github.com:marnyg/kubernetesOnAzure.git /home/mar/git/personal/kubernetesOnAzure
            ${pkgs.git}/bin/git clone git@github.com:marnyg/buildAzureNixImage.git /home/mar/git/personal/buildAzureNixImage
            exit 0
          ''
          }";
          Service.Type = "oneshot";
        };
      home.file."git/hiplog/.envrc".text = envrcString;
      home.file."git/sendra/.envrc".text = envrcString;


    };
}
