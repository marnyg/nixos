{ config, lib, pkgs, ... }:

let
  cfg = config.modules.services.cloneWorkRepos;
in
{
  options.modules.services.cloneWorkRepos = {
    enable = lib.mkEnableOption "Enable Git Repos cloning service";

    gitDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/git/work";
      description = "Directory to clone the repositories to.";
    };

    repoInfo = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({ ... }: {
        options = {
          key = lib.mkOption {
            type = lib.types.str;
            description = "Path to SSH key.";
          };
          repos = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            description = "List of repositories.";
          };
        };
      }));
      default = { };
      description = "Information about the repositories to clone.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.cloneWorkRepos =
      let
        cloneFunctionScript = pkgs.writeScript "clone_functions.sh" ''
          clone() {
            local name=$1
            local repo_name=$(echo $2 | awk -F '/' '{ print $NF }')
            ${pkgs.coreutils}/bin/mkdir -p ${cfg.gitDir}/$name/env/$repo_name
            printf "source_up_if_exists\\nuse flake \"github:marnyg/nixFlakes?dir=$(echo $repo_name | cut -d '.' -f 1)\"" > $name/env/.envrc
            echo "git clone $2 ${cfg.gitDir}/$name/env/$repo_name"
            git clone $2 ./$repo_name/$repo_name
          }
        '';
        cloneRepos = name: info: ''
          export XDG_CONFIG_DIRS="/etc/xdg"  # Set it explicitly to avoid issues.
          ${pkgs.coreutils}/bin/mkdir -p ${cfg.gitDir}/${name}
          cd ${cfg.gitDir}/${name}

          export GIT_SSH_COMMAND="${pkgs.openssh}/bin/ssh -i ${info.key}"

          echo -e "${builtins.concatStringsSep "\\n" info.repos}" | ${pkgs.parallel}/bin/parallel "source ${cloneFunctionScript}; clone ${name} {}"
        '';
      in
      {
        Install.WantedBy = [ "default.target" ];
        Unit.Description = "Clone configured Git repositories";
        Service.ExecStart = pkgs.writeScript "cloneRepos.sh" ''
          #! ${pkgs.bash}/bin/bash
          ${pkgs.openssh}/bin/ssh-keygen -F gitlab.com || ${pkgs.openssh}/bin/ssh-keyscan gitlab.com >> ~/.ssh/known_hosts
          ${builtins.concatStringsSep "\n" (lib.attrsets.mapAttrsToList cloneRepos cfg.repoInfo)}
          exit 0
        '';
        Service.Type = "oneshot";
      };
  };
}
