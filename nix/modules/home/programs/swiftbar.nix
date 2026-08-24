# SwiftBar menu-bar widgets — the macOS counterpart of the quickshell bar
# widgets (see programs/quickshell/). Currently ships one plugin showing
# Claude subscription usage (5h/7d window utilization) in the menu bar.
{ pkgs, lib, config, ... }:
with lib;
{
  options.modules.my.swiftbar = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.my.swiftbar.enable {
    home.packages = [ pkgs.swiftbar ];

    # Point SwiftBar at the nix-managed plugin folder (preempts the
    # first-launch folder picker) and silence Sparkle self-updates since
    # the app is nix-managed.
    targets.darwin.defaults."com.ameba.SwiftBar" = {
      PluginDirectory = "${config.home.homeDirectory}/.config/swiftbar/plugins";
      SUEnableAutomaticChecks = false;
    };

    # Same data source as quickshell's anthropic-usage.sh: OAuth token from
    # pi (preferred) or Claude Code (macOS keychain), then the oauth/usage
    # endpoint. Renders the same Nord pill + progress bars as the quickshell
    # widget into a PNG (2x pixels + 144dpi metadata = crisp retina) and
    # embeds it in the menu bar via SwiftBar's image= param.
    home.file.".config/swiftbar/plugins/anthropic-usage.5m.sh" = {
      executable = true;
      source = pkgs.writeShellScript "anthropic-usage-swiftbar" ''
        # <bitbar.title>Anthropic usage</bitbar.title>
        # <swiftbar.hideAbout>true</swiftbar.hideAbout>
        # <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
        # <swiftbar.hideDisablePlugin>true</swiftbar.hideDisablePlugin>
        set -u
        jq=${pkgs.jq}/bin/jq
        curl=${pkgs.curl}/bin/curl
        magick=${pkgs.imagemagick}/bin/magick
        font=${pkgs.fira-code}/share/fonts/truetype/FiraCode-VF.ttf

        # BSD date has no %N; milliseconds since epoch the portable way
        now=$(( $(date +%s) * 1000 ))
        token=""

        pi_auth="$HOME/.pi/agent/auth.json"
        if [ -f "$pi_auth" ]; then
          exp=$($jq -r '.anthropic.expires // 0' "$pi_auth")
          if [ "$exp" -gt "$now" ]; then
            token=$($jq -r '.anthropic.access // empty' "$pi_auth")
          fi
        fi

        # Claude Code on macOS keeps its OAuth creds in the login keychain
        if [ -z "$token" ]; then
          cc=$(/usr/bin/security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null || true)
          if [ -n "$cc" ]; then
            exp=$(printf '%s' "$cc" | $jq -r '.claudeAiOauth.expiresAt // 0')
            if [ "$exp" -gt "$now" ]; then
              token=$(printf '%s' "$cc" | $jq -r '.claudeAiOauth.accessToken // empty')
            fi
          fi
        fi

        if [ -z "$token" ]; then
          printf '✳ –\n---\nNo valid OAuth token — run pi or claude to refresh\n'
          exit 0
        fi

        usage=$($curl -sf --max-time 10 https://api.anthropic.com/api/oauth/usage \
          -H "Authorization: Bearer $token" \
          -H "anthropic-beta: oauth-2025-04-20") \
          || { printf '✳ !\n---\nUsage fetch failed\n'; exit 0; }

        # kind <tab> label <tab> pct <tab> local reset time <tab> eta
        limits=$(printf '%s' "$usage" | $jq -r '
          def lbl:
            if .kind == "session" then "5h"
            elif .kind == "weekly_all" then "7d"
            else (.scope.model.display_name // .kind) end;
          def eta:
            ((. - now) / 60 | floor) as $m |
            if $m <= 0 then ""
            elif $m >= 1440 then "\($m / 1440 | floor)d \($m % 1440 / 60 | floor)h"
            elif $m >= 60 then "\($m / 60 | floor)h \($m % 60)m"
            else "\($m)m" end;
          .limits[] |
          (.resets_at | sub("\\.[0-9]+"; "") | sub("\\+00:00"; "Z")
            | fromdateiso8601) as $rst |
          [.kind, lbl, (.percent | round),
           ($rst | strflocaltime("%a %H:%M")), ($rst | eta)] | @tsv') \
          || { printf '✳ !\n---\nUsage parse failed\n'; exit 0; }

        # Nord palette, matching quickshell's usageColor()
        usage_color() {
          if [ "$1" -ge 80 ]; then echo '#bf616a'
          elif [ "$1" -ge 50 ]; then echo '#ebcb8b'
          else echo '#b4befe'; fi
        }

        # Render "label [====  ] NN%" meters into a Nord pill PNG; prints
        # base64 on success. All sizes are 2x, shrunk to points by 144dpi.
        render_pill() { # args: label pct [label pct]...
          local tmp i=0 pieces=() color w
          tmp=$(mktemp -d) || return 1
          trap 'rm -rf "$tmp"' RETURN
          while [ $# -ge 2 ]; do
            color=$(usage_color "$2")
            w=$(( 88 * $2 / 100 ))
            [ "$w" -lt 10 ] && w=10; [ "$w" -gt 88 ] && w=88
            if [ "$i" -gt 0 ]; then
              $magick -size 12x1 xc:none "$tmp/spa$i.png"
              $magick -size 1x16 xc:'#434c5e' "$tmp/sep$i.png"
              $magick -size 12x1 xc:none "$tmp/spb$i.png"
              pieces+=("$tmp/spa$i.png" "$tmp/sep$i.png" "$tmp/spb$i.png")
            fi
            $magick -background none -font "$font" -pointsize 20 \
              -fill '#b4befe' label:"$1" "$tmp/lab$i.png"
            $magick -size 88x12 xc:none \
              -fill '#434c5e' -draw 'roundrectangle 0,0 87,11 6,6' \
              -fill "$color" -draw "roundrectangle 0,0 $((w - 1)),11 6,6" \
              "$tmp/bar$i.png"
            $magick -background none -font "$font" -pointsize 20 \
              -fill '#d8dee9' label:"$2%" "$tmp/pct$i.png"
            $magick -size 8x1 xc:none "$tmp/ga$i.png"
            $magick -size 8x1 xc:none "$tmp/gb$i.png"
            pieces+=("$tmp/lab$i.png" "$tmp/ga$i.png" "$tmp/bar$i.png" \
                     "$tmp/gb$i.png" "$tmp/pct$i.png")
            i=$((i + 1)); shift 2
          done
          $magick "''${pieces[@]}" -background none -gravity center +append \
            "$tmp/row.png" || return 1
          local W
          W=$($magick identify -format %w "$tmp/row.png") || return 1
          $magick -size $((W + 40))x36 xc:none \
            -fill '#2e3440' -draw "roundrectangle 0,0 $((W + 39)),35 17,17" \
            "$tmp/row.png" -gravity center -composite \
            -density 144 -units pixelsperinch "$tmp/pill.png" || return 1
          base64 -i "$tmp/pill.png" | tr -d '\n'
        }

        # Menu bar shows every limit, like the quickshell pill; dropdown
        # repeats them with reset ETAs.
        args=()
        while IFS=$'\t' read -r _ label pct _ _; do
          args+=("$label" "$pct")
        done <<< "$limits"

        if [ "''${#args[@]}" -gt 0 ] && img=$(render_pill "''${args[@]}"); then
          echo "| image=$img"
        else
          # Fallback: plain text title
          top=""
          while IFS=$'\t' read -r _ label pct _ _; do
            top="$top''${top:+ · }$label $pct%"
          done <<< "$limits"
          echo "✳ $top"
        fi

        echo "---"
        while IFS=$'\t' read -r _ label pct reset eta; do
          line="$label: $pct% — resets $reset''${eta:+ (in $eta)}"
          if [ "$pct" -ge 50 ]; then
            echo "$line | color=$(usage_color "$pct")"
          else
            echo "$line"
          fi
        done <<< "$limits"
        echo "Refresh | refresh=true"
      '';
    };

    launchd.agents.swiftbar = {
      enable = true;
      config = {
        ProgramArguments = [ "${pkgs.swiftbar}/Applications/SwiftBar.app/Contents/MacOS/SwiftBar" ];
        RunAtLoad = true;
        KeepAlive = false;
      };
    };
  };
}
