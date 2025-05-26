{ lib, config, ... }:
with lib;
{
  options.modules.direnv = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.direnv.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
      config = {
        hide_env_diff = true;
        whitelist.prefix = [ "~/git/nixos" "~/git/personal" "~/git/PerformanceLab" ];
      };
      # stdlib = ''
      #   # hash
      #   : "''${XDG_CACHE_HOME:="''${HOME}/.cache"}"
      #   declare -A direnv_layout_dirs
      #   direnv_layout_dir() {
      #       local hash path
      #       echo "''${direnv_layout_dirs[$PWD]:=''$(
      #           hash="''$(echo "$PWD" | sha1sum | cut -d ' ' -f 1)"
      #           path="''${PWD//[^a-zA-Z0-9]/-}"
      #           echo "''${XDG_CACHE_HOME}/direnv/layouts/''${hash}''${path}"
      #       )}"
      #   }
      #
      #   add_nuget_source() {
      #     local source_url=$1
      #     local source_name=$2
      #     local source_username=$3
      #     local source_password=$4
      #
      #     echo $NUGET_CONFIG_FILE
      #     dotnet nuget add source $source_url --name $source_name --username $source_username --password $source_password --store-password-in-clear-text --configfile $NUGET_CONFIG_FILE 
      #   }
      #
      #   get_bw_token() {
      #     local cache_file="/tmp/bwCache/session"
      #
      #     if [[ -f $cache_file ]]; then
      #       export BW_SESSION=$(cat $cache_file)
      #       # Try a benign command to check if the session is still valid
      #       if ${pkgs.bitwarden-cli}/bin/bw list items --session $BW_SESSION > /dev/null 2>&1; then
      #         # Command succeeded, session key is valid
      #         echo $BW_SESSION
      #         return
      #       fi
      #     fi
      #
      #     # If we reached here, we either don't have a session key or it's invalid.
      #     # Get a new one.
      #     mkdir -p $(dirname $cache_file) # Ensure the cache directory exists
      #     export BW_SESSION=$(${pkgs.bitwarden-cli}/bin/bw unlock --raw)
      #     echo $BW_SESSION > $cache_file
      #     echo $BW_SESSION
      #   }
      #
      #
      #   get_secret() {
      #     local item_id=$1
      #     local field=$2 # 'password' or 'username'
      #     local cache_file="/tmp/bwCache/''${item_id}_''${field}"
      #     local now=$(date +%s)
      #     local expiry=36000 # Cache expiry time in seconds - 10 hours
      #
      #     # Check if the cache file exists
      #     if [[ -f $cache_file ]]; then
      #       # Read the file content and calculate the file age
      #       local file_content=$(awk '{$1=$1};1' < $cache_file)
      #       local file_age=$(($now - $(date -r $cache_file +%s)))
      #
      #       # Check if the cache file is not empty and is still valid
      #       if [[ -n $file_content ]] && [[ $file_age -lt $expiry ]]; then
      #         cat $cache_file
      #         return
      #       fi
      #     fi
      #
      #     # If we reach here, we either don't have a cache file or it's expired/empty
      #     mkdir -p $(dirname $cache_file) # Ensure the cache directory exists
      #     ${pkgs.bitwarden-cli}/bin/bw get $field $item_id > $cache_file
      #     cat $cache_file
      #   }
      #
      # '';
    };
  };
}
