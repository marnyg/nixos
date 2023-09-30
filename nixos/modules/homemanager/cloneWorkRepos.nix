{ config, lib, pkgs, ... }:

let
  cfg = config.modules.services.cloneWorkRepos;

  cloneRepos = name: info: ''
    mkdir -p ${cfg.gitDir}/${name}
    cd ${cfg.gitDir}/${name}

    export GIT_SSH_COMMAND="${pkgs.openssh}/bin/ssh -i ${info.key}"

    clone_${name}() {
      local repo_name=$(echo $1 | awk -F '/' '{ print $NF }')
      mkdir -p ${cfg.gitDir}/${name}/$repo_name/$repo_name
      printf "source_up_if_exists\\nuse flake \"github:marnyg/nixFlakes?dir=$(echo $repo_name | cut -d '.' -f 1)\"" > $repo_name/.envrc
      echo "git clone $1 ./$repo_name/$repo_name"
      git clone $1 ./$repo_name/$repo_name
    }
    export -f clone_${name}

    echo -e "${builtins.concatStringsSep "\\n" info.repos}" | ${pkgs.parallel}/bin/parallel clone_${name}
  '';
in
{
  options.modules.services.cloneWorkRepos= {
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
    systemd.user.services.cloneGitRepos = {
      Install.WantedBy = [ "default.target" ];
      Unit.After = [ "copySshFromHost" ];
      Unit.Description = "Clone configured Git repositories";
      Service.ExecStart = pkgs.writeScript "cloneRepos.sh" ''
        ${pkgs.openssh}/bin/ssh-keygen -F gitlab.com || ${pkgs.openssh}/bin/ssh-keyscan gitlab.com >> ~/.ssh/known_hosts
        ${builtins.concatStringsSep "\n" (lib.attrsets.mapAttrsToList cloneRepos cfg.repoInfo)}
        exit 0
      '';
      Service.Type = "oneshot";
    };
  };
}
