{ pkgs, lib, config, secretPaths, ... }:
with lib;
{
  options.modules.my.tailscale-autoconnect = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkMerge [
    # Autoconnect (opt-in via modules.my.tailscale-autoconnect.enable):
    (mkIf config.modules.my.tailscale-autoconnect.enable {
      services.tailscale.enable = true;
      services.tailscale.port = 12345;

      age.secrets.tailscaleAuthKey = {
        file = secretPaths.tailscaleAuthKey;
        owner = "root";
        group = "root";
        mode = "0400";
      };

      systemd.services.tailscale-autoconnect = {
        description = "Automatic connection to Tailscale";
        after = [ "network-pre.target" "tailscale.service" ];
        wants = [ "network-pre.target" "tailscale.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig.Type = "oneshot";
        script = with pkgs; ''
          sleep 2
          status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
          if [ "$status" != "Running" ]; then
            ${tailscale}/bin/tailscale up \
              --authkey "$(cat ${config.age.secrets.tailscaleAuthKey.path})" \
              --accept-dns=true \
              --reset
          fi

          # Wait for tailscale0 to get its IPs, then force a clean DNS re-push
          # to work around the self-induced "major link change" race that drops
          # the MagicDNS LocalDomain on tailscaled 1.98.
          for i in $(seq 1 30); do
            if ${tailscale}/bin/tailscale ip -4 >/dev/null 2>&1; then break; fi
            sleep 1
          done
          sleep 3
          ${tailscale}/bin/tailscale set --accept-dns=false || true
          sleep 1
          ${tailscale}/bin/tailscale set --accept-dns=true || true
        '';
      };
    })

    # DNS-drift watchdog: enabled for every host that has tailscale, regardless
    # of whether the autoconnect is used. Works around tailscaled+systemd-resolved
    # race where a rebind clobbers MagicDNS (Nameservers becomes the upstream
    # 199.x instead of 100.100.100.100), making *.<tailnet>.ts.net unresolvable.
    (mkIf config.services.tailscale.enable {
      systemd.services.tailscale-dns-watchdog = {
        description = "Re-push Tailscale MagicDNS if systemd-resolved drifts";
        after = [ "tailscaled.service" ];
        wants = [ "tailscaled.service" ];
        serviceConfig.Type = "oneshot";
        script = with pkgs; ''
          # Only act if tailscale is up.
          if ! ${tailscale}/bin/tailscale status >/dev/null 2>&1; then
            exit 0
          fi
          # If the tailscale0 link in systemd-resolved isn't using the MagicDNS
          # resolver (100.100.100.100), bounce --accept-dns to force a re-push.
          if ! ${systemd}/bin/resolvectl status tailscale0 2>/dev/null \
              | ${gnugrep}/bin/grep -q '100\.100\.100\.100'; then
            ${tailscale}/bin/tailscale set --accept-dns=false || true
            sleep 1
            ${tailscale}/bin/tailscale set --accept-dns=true || true
          fi
        '';
      };
      systemd.timers.tailscale-dns-watchdog = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "30s";
          OnUnitActiveSec = "1min";
          Unit = "tailscale-dns-watchdog.service";
        };
      };
    })
  ];
}
