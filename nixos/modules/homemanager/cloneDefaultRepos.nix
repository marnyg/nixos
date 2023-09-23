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
          Unit.ConditionFileNotEmpty = ["/home/mar/.ssh/githubmarnyg"];
          Service.ExecStart = "/bin/sh ${pkgs.writeScript "cloneMyStuff.sh" ''
            ${pkgs.openssh}/bin/ssh-keygen -F github.com || ${pkgs.openssh}/bin/ssh-keyscan github.com >> ~/.ssh/known_hosts
            export GIT_SSH_COMMAND="${pkgs.openssh}/bin/ssh -i /home/mar/.ssh/githubmarnyg"
            ${pkgs.coreutils}/bin/mkdir /home/mar/git
            ${pkgs.git}/bin/git clone git@github.com:marnyg/nixos.git /home/mar/git/nixos
            ${pkgs.git}/bin/git clone git@github.com:marnyg/kubernetesOnAzure.git /home/mar/git/nixos
            ${pkgs.git}/bin/git clone git@github.com:marnyg/buildAzureNixImage.git /home/mar/git/nixos
            exit 0
          ''
          }";
          Service.Type = "oneshot";
        };
      home.file."git/hiplog/.envrc".text=''
use flake

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
      home.file."git/sendra/.envrc".text=''
use flake

#TODO: move this logic into a nix expression/flake
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


      home.file."git/sendra/nix/devops/flake.nix".text=''
{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    let pkgs = (import nixpkgs { system = "x86_64-linux"; }); in
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system:
      let pkgs = (import nixpkgs { inherit system; }); in
      {
        devShells.default = pkgs.mkShell { nativeBuildInputs = with pkgs; [ terraform ]; };
        formatter = pkgs.nixpkgs-fmt;
      });
}
      '';

      home.file."git/hiplog/flake.nix".text=''
      {
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    let pkgs = (import nixpkgs { system = "x86_64-linux"; }); in
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system:
      let pkgs = (import nixpkgs { inherit system; }); in
      {
        devShells.default =
          let
            #making adhock shell scripts
            myArbetraryCommand = pkgs.writeShellScriptBin "tst" ''' ''${pkgs.cowsay}/bin/cowsay lalal ''';
            drest = pkgs.writeShellScriptBin "drest.sh" "dotnet restore --configfile $NUGET_CONFIG_FILE";

          in
          pkgs.mkShell {

            nativeBuildInputs = with pkgs; [

              #lsp-servers
              # TODO: add dotnet nuget node 
              nodePackages_latest.bash-language-server # Bash LSP server
              omnisharp-roslyn

              myArbetraryCommand
              drest

              dotnet-sdk_6
              #dotnet-runtime_6
              shfmt
              clippy
            ];
            shellHook = '''
              export LSP_SERVERS="omnisharp,OmniSharp bashls "
            ''';
          };
        formatter = pkgs.nixpkgs-fmt;
      });
   }

      '';
      home.file."git/sendra/flake.nix".text=''
      {
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    let pkgs = (import nixpkgs { system = "x86_64-linux"; }); in
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system:
      let pkgs = (import nixpkgs { inherit system; }); in
      {
        devShells.default =
          let
            #making adhock shell scripts
            myArbetraryCommand = pkgs.writeShellScriptBin "tst" ''' ''${pkgs.cowsay}/bin/cowsay lalal ''';
            drest = pkgs.writeShellScriptBin "drest.sh" "dotnet restore --configfile $NUGET_CONFIG_FILE";

          in
          pkgs.mkShell {

            nativeBuildInputs = with pkgs; [

              #lsp-servers
              # TODO: add dotnet nuget node 
              nodePackages_latest.bash-language-server # Bash LSP server
              omnisharp-roslyn

              myArbetraryCommand
              drest

              dotnet-sdk_6
              #dotnet-runtime_6
              shfmt
              clippy
            ];
            shellHook = '''
              export LSP_SERVERS="omnisharp,OmniSharp bashls "
            ''';
          };
        formatter = pkgs.nixpkgs-fmt;
      });
   }

      '';
      systemd.user.services.cloneWorkRepos = {
        #Install.WantedBy = [ "multi-user.target" ]; # starts after login
        Install.WantedBy = [ "default.target" ]; # starts after login
        Unit.After = [ "copySshFromHost" ];
        Unit.Description = "Example description";
        Unit.ConditionFileNotEmpty = ["/home/mar/.ssh/id_rsa" "/home/mar/.ssh/id_ed25519"];
        Service.ExecStart = "/bin/sh ${pkgs.writeScript "cloneWorkStuff.sh" ''
          ${pkgs.openssh}/bin/ssh-keygen -F gitlab.com || ${pkgs.openssh}/bin/ssh-keyscan gitlab.com >> ~/.ssh/known_hosts
          #sendra
          #TODO: can i remove this, since home-manager is creating a flake in this folder?
          #TODO: use parralell:    
          #    clone_hiplog() {
          #      ''${pkgs.git}/bin/git clone git@gitlab-well:wellstarter/hiplog/$1.git
          #    }
          #    export -f clone_hiplog
          #          echo -e "''${builtins.concatStringsSep "\\n" hiplogRepos}" | ''${pkgs.parallel}/bin/parallel clone_hiplog

          ${pkgs.coreutils}/bin/mkdir /home/mar/git/sendra
          cd /home/mar/git/sendra
          export GIT_SSH_COMMAND="${pkgs.openssh}/bin/ssh -i /home/mar/.ssh/id_rsa"
          ${pkgs.git}/bin/git clone git@gitlab.com:prores/sendra/devops.git
          ${pkgs.git}/bin/git clone git@gitlab.com:prores/fieldview/field-view-api.git
          ${pkgs.git}/bin/git clone git@gitlab.com:prores/sendra/keycloak-image.git
          ${pkgs.git}/bin/git clone git@gitlab.com:prores/sendra/sendra-cli.git
          ${pkgs.git}/bin/git clone git@gitlab.com:prores/sendra/sendra.git
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
          ${pkgs.git}/bin/git clone git@gitlab.com:prores/sendra/sendra-release-tools.git
          #wellstarter
          #TODO, can i remove this, since home-manager is creating a flake in this folder?
          ${pkgs.coreutils}/bin/mkdir /home/mar/git/hiplog
          cd /home/mar/git/hiplog
          export GIT_SSH_COMMAND="${pkgs.openssh}/bin/ssh -i /home/mar/.ssh/id_ed25519"
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
          exit 0
        ''
        }";
        Service.Type = "oneshot";
      };


    };
}
