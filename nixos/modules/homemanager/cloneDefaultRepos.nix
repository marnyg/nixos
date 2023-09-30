{ pkgs, lib, config, ... }:
with lib;
let
  ## Extract common strings from Home Manager's config
  #homeDir = config.home.homeDirectory;
  #sshDir = "${homeDir}/.ssh";
  #gitDir = "${homeDir}/git";

  ## Define repositories information
  #repoInfo = {
  #  sendra = {
  #    key = "${sshDir}/id_rsa";
  #    gitlabRoot = "prores";
  #    repos = [ 
  #    "devops" 
  #    "field-view-api" 
  #    "keycloak-image" 
  #    ];
  #  };
  #  hiplog = {
  #    key = "${sshDir}/id_ed25519";
  #    gitlabRoot = "wellstarter";
  #    repos = [ 
  #    "audit-trail" 
  #    "compose"
  #    "data-interpreter" ];
  #  };
  #};

  ## Function to clone repositories
  #cloneRepos = name: info: ''
  #  mkdir -p ${cfg.gitDir}/${name}
  #  cd ${cfg.gitDir}/${name}

  #  export GIT_SSH_COMMAND="${pkgs.openssh}/bin/ssh -i ${info.key}"

  #  clone_${name}() {
  #    local repo_name=$(echo $1 | awk -F '/' '{ print $NF }')
  #    printf "source_up_if_exists\\nuse flake ../../nix/$(basename $PWD)" > $repo_name/.envrc
  #    mkdir -p ${cfg.gitDir}/${name}/$repo_name/$repo_name
  #    git clone git@gitlab.com:${info.gitlabRoot}/$1.git ./$repo_name/$repo_name
  #  }
  #  export -f clone_${name}

  #  echo -e "${builtins.concatStringsSep "\\n" info.repos}" | ${pkgs.parallel}/bin/parallel clone_${name}
  #'';

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
        #TODO: move this logic into a nix expression/flake
        export BW_SESSION=$(${pkgs.bitwarden-cli}/bin/bw login --raw)
        ${pkgs.bitwarden-cli}/bin/bw get notes prores-gitlab-ssh.priv > /home/mar/.ssh/id_rsa
        ${pkgs.bitwarden-cli}/bin/bw get notes wellstarter-gitlab-ssh.priv > /home/mar/.ssh/id_ed25519
        ${pkgs.bitwarden-cli}/bin/bw get notes personal-github-ssh.priv > /home/mar/.ssh/githubmarnyg

        ${pkgs.findutils}/bin/find /home/mar/.ssh/* -type f -print0 | ${pkgs.findutils}/bin/xargs -0 ${pkgs.coreutils}/bin/chmod 0600 

        ${pkgs.openssh}/bin/ssh-keygen -y -f /home/mar/.ssh/id_ed25519 > id_ed25519.pub
        ${pkgs.openssh}/bin/ssh-keygen -y -f /home/mar/.ssh/id_rsa > id_rsa.pub
        ${pkgs.openssh}/bin/ssh-keygen -y -f /home/mar/.ssh/githubmarnyg > githubmarnyg.pub



        #TODO: add checks to see if it worked
        #TODO: if it worked run:
        #      systemctl start --user cloneWorkRepos.service
        #      systemctl start --user cloneDefaultRepos.service

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
            git clone git@github.com:marnyg/nixos.git /home/mar/git/nixos
            git clone git@github.com:marnyg/kubernetesOnAzure.git /home/mar/git/personal/kubernetesOnAzure
            git clone git@github.com:marnyg/buildAzureNixImage.git /home/mar/git/personal/buildAzureNixImage
            exit 0
          ''
          }";
          Service.Type = "oneshot";
        };
      home.file."git/hiplog/.envrc".text = envrcString;
      home.file."git/sendra/.envrc".text = envrcString;

      #systemd.user.services.cloneWorkRepos = {
      #  Install.WantedBy = [ "default.target" ];
      #  Unit.After = [ "copySshFromHost" ];
      #  Unit.Description = "Example description";
      #  Service.ExecStart = pkgs.writeScript "cloneWorkStuff.sh" ''
      #    ${pkgs.openssh}/bin/ssh-keygen -F gitlab.com || ${pkgs.openssh}/bin/ssh-keyscan gitlab.com >> ~/.ssh/known_hosts
      #    ${builtins.concatStringsSep "\n" (lib.attrsets.mapAttrsToList cloneRepos repoInfo)}
      #    exit 0
      #  '';
      #  Service.Type = "oneshot";
      #};


      #git@github.com:marnyg/nixFlakes.git /home/mar/git/sendra/nix
      #git@gitlab.com:prores/sendra/devops.git
      #git@gitlab.com:prores/fieldview/field-view-api.git
      #git@gitlab.com:prores/sendra/keycloak-image.git
      #git@gitlab.com:prores/sendra/sendra-cli.git
      #git@gitlab.com:prores/sendra/sendra.git
      #git@gitlab.com:prores/sendra/sendra-compose.git
      #git@gitlab.com:prores/sendra/sendra-engine.git
      #git@gitlab.com:prores/sendra/sendra-importer.git
      #git@gitlab.com:prores/sendra/sendra-integrationtests.git
      #git@gitlab.com:prores/sendra/sendra-keycloak-theme.git
      #git@gitlab.com:prores/sendra/sendra-settings.git
      #git@gitlab.com:prores/sendra/sendra-sona.git
      #git@gitlab.com:prores/sendra/sendra-userservice.git
      #git@gitlab.com:prores/sendra/sendra-web.git
      #git@gitlab.com:prores/sendra/sendra-units.git
      #git@gitlab.com:prores/sendra/sendra-exporter.git
      #git@gitlab.com:prores/sendra/sendra-database.git
      #git@gitlab.com:prores/sendra/sendra-contract.git
      #git@gitlab.com:prores/sendra/sendra-assets.git
      #git@gitlab.com:prores/sendra/sendra-release-tools.git
      # #wellstarter
      # #TODO, can i remove this, since home-manager is creating a flake in this folder?
      # ${pkgs.coreutils}/bin/mkdir /home/mar/git/hiplog
      # cd /home/mar/git/hiplog
      # export GIT_SSH_COMMAND="${pkgs.openssh}/bin/ssh -i /home/mar/.ssh/id_ed25519"
      # ${pkgs.git}/bin/git clone git@gitlab-well:wellstarter/audit-trail.git
      # ${pkgs.git}/bin/git clone git@gitlab-well:wellstarter/hiplog/compose.git
      # ${pkgs.git}/bin/git clone git@gitlab-well:wellstarter/hiplog/data-interpreter.git
      # ${pkgs.git}/bin/git clone git@gitlab-well:wellstarter/hiplog/devops.git
      # ${pkgs.git}/bin/git clone git@gitlab-well:wellstarter/hiplog/filestore.git
      # ${pkgs.git}/bin/git clone git@gitlab-well:wellstarter/hiplog/filestore-client.git
      # ${pkgs.git}/bin/git clone git@gitlab-well:wellstarter/hiplog/forward-modeling.git
      # ${pkgs.git}/bin/git clone git@gitlab-well:wellstarter/hiplog-fe-nuxt3.git
      # ${pkgs.git}/bin/git clone git@gitlab-well:wellstarter/hiplog-matlab.git
      # ${pkgs.git}/bin/git clone git@gitlab-well:wellstarter/matlab-runner.git
      # ${pkgs.git}/bin/git clone git@gitlab-well:wellstarter/matlab-runtime.git
      # ${pkgs.git}/bin/git clone git@gitlab-well:wellstarter/hiplog/pdf-converter.git
      # ${pkgs.git}/bin/git clone git@gitlab-well:wellstarter/hiplog/units.git
      # ${pkgs.git}/bin/git clone git@gitlab-well:wellstarter/hiplog/user-service.git
      # ${pkgs.git}/bin/git clone git@gitlab-well:wellstarter/hiplog/wells-backend.git

      # home.file."git/hiplog/flake.nix".text = ''
      #       {
      #   description = "NixOS configuration";
      #
      #   inputs = {
      #     nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
      #     flake-utils.url = "github:numtide/flake-utils";
      #   };
      #
      #   outputs = { self, nixpkgs, flake-utils, ... }@inputs:
      #     let pkgs = (import nixpkgs { system = "x86_64-linux"; }); in
      #     flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system:
      #       let pkgs = (import nixpkgs { inherit system; }); in
      #       {
      #         devShells.default =
      #           let
      #             #making adhock shell scripts
      #             myArbetraryCommand = pkgs.writeShellScriptBin "tst" ''' ''${pkgs.cowsay}/bin/cowsay lalal ''';
      #             drest = pkgs.writeShellScriptBin "drest.sh" "dotnet restore --configfile $NUGET_CONFIG_FILE";
      #
      #           in
      #           pkgs.mkShell {
      #
      #             nativeBuildInputs = with pkgs; [
      #
      #               #lsp-servers
      #               # TODO: add dotnet nuget node 
      #               nodePackages_latest.bash-language-server # Bash LSP server
      #               omnisharp-roslyn
      #
      #               myArbetraryCommand
      #               drest
      #
      #               dotnet-sdk_6
      #               #dotnet-runtime_6
      #               shfmt
      #               clippy
      #             ];
      #             shellHook = '''
      #               export LSP_SERVERS="omnisharp,OmniSharp bashls "
      #             ''';
      #           };
      #         formatter = pkgs.nixpkgs-fmt;
      #       });
      #    }
      #
      # '';


    };
}
