{ pkgs, lib, config, ... }:
with lib;
{
  options.modules.my.quickshell = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.my.quickshell.enable {
    home.packages = [ pkgs.quickshell ];

    xdg.configFile."quickshell/shell.qml".source = ./shell.qml;

    # Fetches Claude subscription usage (5h/7d window utilization) using the
    # OAuth token from pi (preferred) or Claude Code. Emits one compact JSON
    # line for the bar widget.
    xdg.configFile."quickshell/anthropic-usage.sh".source = pkgs.writeShellScript "anthropic-usage" ''
      set -eu
      jq=${pkgs.jq}/bin/jq
      curl=${pkgs.curl}/bin/curl

      now=$(date +%s%3N)
      token=""

      pi_auth="$HOME/.pi/agent/auth.json"
      if [ -f "$pi_auth" ]; then
        exp=$($jq -r '.anthropic.expires // 0' "$pi_auth")
        if [ "$exp" -gt "$now" ]; then
          token=$($jq -r '.anthropic.access // empty' "$pi_auth")
        fi
      fi

      cc_auth="$HOME/.claude/.credentials.json"
      if [ -z "$token" ] && [ -f "$cc_auth" ]; then
        exp=$($jq -r '.claudeAiOauth.expiresAt // 0' "$cc_auth")
        if [ "$exp" -gt "$now" ]; then
          token=$($jq -r '.claudeAiOauth.accessToken // empty' "$cc_auth")
        fi
      fi

      if [ -z "$token" ]; then
        echo '{"error":"no valid token"}'
        exit 0
      fi

      $curl -sf --max-time 10 https://api.anthropic.com/api/oauth/usage \
        -H "Authorization: Bearer $token" \
        -H "anthropic-beta: oauth-2025-04-20" \
        | $jq -c '{limits: [.limits[] | {
            label: (if .kind == "session" then "5h"
                    elif .kind == "weekly_all" then "7d"
                    else (.scope.model.display_name // .kind) end),
            pct: .percent,
            resets: .resets_at
          }]}' \
        || echo '{"error":"fetch failed"}'
    '';

    # Fetches OpenRouter balance and recent spend. Reads the API key from the
    # agenix secret (same source the shells export OPENROUTER_API_KEY from),
    # falling back to the env var. Emits one compact JSON line.
    xdg.configFile."quickshell/openrouter-usage.sh".source = pkgs.writeShellScript "openrouter-usage" ''
      set -u
      jq=${pkgs.jq}/bin/jq
      curl=${pkgs.curl}/bin/curl

      secret="${optionalString (config.age.secrets ? openrouterToken) config.age.secrets.openrouterToken.path}"
      token=""
      if [ -n "$secret" ] && [ -r "$secret" ]; then
        token=$(cat "$secret")
      fi
      [ -z "$token" ] && token="''${OPENROUTER_API_KEY:-}"

      if [ -z "$token" ]; then
        echo '{"error":"no token"}'
        exit 0
      fi

      credits=$($curl -sf --max-time 10 https://openrouter.ai/api/v1/credits \
        -H "Authorization: Bearer $token") || { echo '{"error":"fetch failed"}'; exit 0; }
      key=$($curl -sf --max-time 10 https://openrouter.ai/api/v1/key \
        -H "Authorization: Bearer $token") || { echo '{"error":"fetch failed"}'; exit 0; }

      printf '%s\n%s\n' "$credits" "$key" | $jq -cs '{
        remaining: (.[0].data.total_credits - .[0].data.total_usage),
        day: .[1].data.usage_daily,
        week: .[1].data.usage_weekly
      }'
    '';

    # Tray applets (previously pulled in by the waybar module)
    services.blueman-applet.enable = true;
    services.network-manager-applet.enable = true;

    systemd.user.services.quickshell = {
      Unit = {
        Description = "Quickshell desktop shell";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        X-Restart-Triggers = [ "${config.xdg.configFile."quickshell/shell.qml".source}" ];
      };
      Service = {
        ExecStart = "${pkgs.quickshell}/bin/quickshell";
        Restart = "on-failure";
        RestartSec = 1;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
