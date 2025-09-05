{ pkgs, lib, config, secretPaths, ... }:
with lib;
{
  options.modules.tailscale-autoconnect = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.tailscale-autoconnect.enable {
    services.tailscale.enable = true;
    services.tailscale.port = 12345;

    # Require the tailscale auth key secret from flake outputs
    age.secrets.tailscaleAuthKey = {
      file = secretPaths.tailscaleAuthKey;
      owner = "root";
      group = "root";
      mode = "0400";
    };

    systemd.services.tailscale-autoconnect = {
      description = "Automatic connection to Tailscale";

      # make sure tailscale is running before trying to connect to tailscale
      after = [ "network-pre.target" "tailscale.service" ];
      wants = [ "network-pre.target" "tailscale.service" ];
      wantedBy = [ "multi-user.target" ];

      # set this service as a oneshot job
      serviceConfig.Type = "oneshot";

      # have the job run this shell script
      script = with pkgs; ''
        # wait for tailscaled to settle
        sleep 2

        # check if we are already authenticated to tailscale
        status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
        if [ $status = "Running" ]; then # if so, then do nothing
          exit 0
        fi

        # otherwise authenticate with tailscale
        ${tailscale}/bin/tailscale up -authkey "$(cat ${config.age.secrets.tailscaleAuthKey.path})"
      '';
    };
  };
}
