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
        default = "filesync";
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
        default = "${config.home.homeDirectory}/sync";
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
          "${pkgs.coreutils}/bin/mkdir -p ${cfg.mountPoint}"
          "${pkgs.bash}/bin/bash -c '${pkgs.coreutils}/bin/echo \"${cfg.keyId}:${cfg.accessKey}\" > ${config.home.homeDirectory}/.config/s3fs-passwd && ${pkgs.coreutils}/bin/chmod 0600 ${config.home.homeDirectory}/.config/s3fs-passwd'"
        ];
        ExecStart = toString [
          "${pkgs.goofys}/bin/goofys"
          cfg.bucket
          cfg.mountPoint
          "--endpoint ${cfg.url}"
          "--profile tigris"
          "${concatStringsSep " " cfg.extraOptions}"
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
