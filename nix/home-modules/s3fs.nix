{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myServices.s3fs;
in
{
  options = {
    myServices.s3fs = {
      enable = mkEnableOption "Mount an S3 bucket using s3fs";

      bucket = mkOption {
        type = types.str;
        default = "disksync";
        description = "Name of the S3 bucket to mount.";
      };

      keyId = mkOption {
        type = types.str;
        description = "AWS Access Key ID.";
      };

      accessKey = mkOption {
        type = types.str;
        description = "AWS Secret Access Key.";
      };

      url = mkOption {
        type = types.str;
        default = "https://fly.storage.tigris.dev";
        description = "AWS S3 region.";
      };

      mountPoint = mkOption {
        type = types.str;
        default = "${config.home.homeDirectory}/s3";
        description = "Local mount point for the S3 bucket.";
      };

      extraOptions = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Extra options for s3fs.";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.s3fs ];

    systemd.user.services.s3fs = {
      Unit = {
        Description = "Mount S3 bucket via s3fs (User)";
        After = [ "default.target" ];
        Requires = [ "default.target" ];
      };

      Service = {
        ExecStartPre = [
          # "${pkgs.coreutils}/bin/mkdir -p ${cfg.mountPoint}"
          "${pkgs.bash}/bin/bash -c '${pkgs.coreutils}/bin/echo \"${cfg.keyId}:${cfg.accessKey}\" > ${config.home.homeDirectory}/.config/s3fs-passwd && ${pkgs.coreutils}/bin/chmod 0600 ${config.home.homeDirectory}/.config/s3fs-passwd'"
        ];
        ExecStart = toString [
          "${pkgs.s3fs}/bin/s3fs"
          "-o passwd_file=%h/.config/s3fs-passwd"
          "-o use_path_request_style"
          "-o url=${cfg.url}"
          "-o nonempty"
          "-f"

          #debug options
          # "-o dbglevel=debug"
          # "-o curldbg"
          # "-d"

          "${concatStringsSep " " cfg.extraOptions}"
          "${cfg.bucket} ${cfg.mountPoint}"
        ];
        ExecStop = "${pkgs.fuse}/bin/fusermount -u ${cfg.mountPoint}";
        Restart = "always";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
