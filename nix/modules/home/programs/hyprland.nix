# Hyprland Wayland compositor configuration
{ pkgs, lib, config, ... }:
with lib;
{
  options.modules.my.hyprland = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Hyprland Wayland compositor with custom configuration";
    };
  };

  config = mkIf config.modules.my.hyprland.enable {


    modules.my.wofi.enable = true;
    modules.my.waybar.enable = mkDefault true;
    programs.waybar.systemd.enable = mkDefault true;
    home.packages = [ pkgs.wl-clipboard ];
    services.mako = {
      enable = true; # notification daemon
      settings = {
        # catppuccin.enable = true;
        actions = true;
        anchor = "top-right";
        borderRadius = 8;
        borderSize = 1;
        defaultTimeout = 10000;

        icons = true;
        layer = "overlay";
        maxVisible = 3;
        padding = "10";
        width = 300;
        "urgency=normal".border-color = "#d08770";
        "urgency=high".border-color = "#bf616a";
        "urgency=high".default-timeout = 0;
        "app-name=lightcord".border-color = "#88c0d0";
        "summary~=\"log-.*\"".border-color = "#a3be8c";
      };
    };

    # dimmin screen at night
    services.wlsunset = {
      enable = true;
      latitude = "59.9";
      longitude = "10.7";
    };

    wayland.windowManager.hyprland.enable = true;
    # Native Lua config (Hyprland >= 0.51, hl.* API). Home Manager writes
    # ~/.config/hypr/hyprland.lua from `extraConfig` below. See
    # https://wiki.hypr.land/Configuring/Start/ and the shipped
    # $out/share/hypr/stubs/hl.meta.lua for the full API surface.
    wayland.windowManager.hyprland.configType = "lua";
    wayland.windowManager.hyprland.extraConfig = ''
      -- Main modifier
      local mainMod = "ALT"

      -- Cursor theme/size: kept as Lua locals so the XCURSOR_* env vars (for
      -- children) and the `hyprctl setcursor` autostart (for Hyprland itself)
      -- can't drift apart.
      local cursorTheme = "Nordzy"
      local cursorSize  = "14"

      -- Monitors, matched by EDID description (make + model + serial) instead
      -- of DRM connector name so re-plugging between GPU/iGPU ports or
      -- HDMI<->DP doesn't require a config edit. Connector names (HDMI-A-1
      -- etc.) are assigned by DRM enumeration order across cards and are not
      -- stable.
      --
      -- G70B is capped at 4K@60 over HDMI: the monitor's HDMI port is HDMI 2.0
      -- and its EDID only advertises 4K@30/4K@60 -- no 4K@120 even with 4:2:0.
      -- To unlock 4K@120/144 you need DisplayPort (DP 1.4 + DSC), driving the
      -- monitor GPU-to-monitor directly (the KVM has no DP inputs).
      hl.monitor({ output = "desc:Samsung Electric Company Odyssey G70B H1AK500000", mode = "3840x2160@60", position = "1080x0", scale = 1.0 })
      hl.monitor({ output = "desc:Samsung Electric Company S24F350 H4ZKA04779", mode = "1920x1080@60", position = "0x0", scale = 1, transform = 3 })
      hl.monitor({ output = "desc:Acer Technologies VG272 S 0x11017B67", mode = "1920x1080@144", position = "4920x0", scale = 1.0, transform = 1 })

      -- Look, feel and input
      hl.config({
        -- Variable Refresh Rate: 2 = enable only for fullscreen apps. Panels
        -- that don't advertise VRR in their EDID silently ignore this.
        misc = { vrr = 2 },
        input = {
          kb_layout = "us",
          kb_options = "caps:escape",
          numlock_by_default = true,
          follow_mouse = 0,
          sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.
          touchpad = { natural_scroll = false },
        },
        -- NVIDIA + Wayland: software cursors avoid the hardware-cursor
        -- corruption/flicker seen on the proprietary driver. Replaces the
        -- legacy WLR_NO_HARDWARE_CURSORS=1 env.
        cursor = { no_hardware_cursors = true },
        general = {
          gaps_in = 3,
          gaps_out = 5,
          border_size = 2,
          col = {
            active_border = { colors = { "rgb(5e81ac)", "rgb(5e81ac)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
          },
          layout = "dwindle",
        },
        decoration = { rounding = 3 },
        animations = { enabled = false },
        dwindle = { preserve_split = true, force_split = 1 },
      })

      -- Environment variables passed to Hyprland's children.
      -- LIBVA_DRIVER_NAME / __GLX_VENDOR_LIBRARY_NAME are set system-wide in
      -- modules/nixos/hardware/nvidia.nix, so don't duplicate them here.
      hl.env("XCURSOR_SIZE", cursorSize)
      hl.env("XCURSOR_THEME", cursorTheme)
      hl.env("CLUTTER_BACKEND", "wayland")
      hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
      hl.env("XDG_SESSION_TYPE", "wayland")
      hl.env("XDG_SESSION_DESKTOP", "Hyprland")
      hl.env("QT_QPA_PLATFORM", "wayland;xcb")

      -- Autostart
      hl.on("hyprland.start", function()
        hl.exec_cmd("hyprctl setcursor " .. cursorTheme .. " " .. cursorSize)
      end)

      -- Application / utility keybinds
      hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("firefox"))
      hl.bind(mainMod .. " + return", hl.dsp.exec_cmd("ghostty"))
      hl.bind(mainMod .. " + Q", hl.dsp.window.close())
      hl.bind("CTRL + ALT + SHIFT + Q", hl.dsp.exit())
      hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
      hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
      hl.bind(mainMod .. " + S", hl.dsp.layout("togglesplit"))
      hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("wofi --show drun"))
      hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("wofi --show run"))
      -- Release-triggered so `pkill wofi` fires on key-up: avoids relaunching
      -- wofi while mainMod+P is still physically held.
      hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("pkill wofi || wofi --show drun -i -I"), { release = true })
      -- Region select -> annotate in satty (flameshot gui replacement); Enter copies + saves, then exits
      hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd([[mkdir -p ~/Pictures/Screenshots && grim -g "$(slurp)" - | satty --filename - --output-filename ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png --early-exit --copy-command wl-copy]]))
      -- Whole desktop -> file
      hl.bind("Print", hl.dsp.exec_cmd([[mkdir -p ~/Pictures/Screenshots && grim ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png]]))
      -- Current monitor -> file
      hl.bind("SHIFT + Print", hl.dsp.exec_cmd([[mkdir -p ~/Pictures/Screenshots && grim -o "$(hyprctl monitors -j | jq -r '.[] | select(.focused).name')" ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png]]))
      -- Screenshot applet: wofi menu (region/window/monitor/full -> annotate/clipboard/file)
      hl.bind("SUPER + Print", hl.dsp.exec_cmd("screenshot-menu"))
      hl.bind("SUPER + SHIFT + V", hl.dsp.exec_cmd([[cliphist list | wofi --dmenu | cliphist decode | wl-copy]]))
      hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd([[echo -e "Lock\nLogout\nSuspend\nReboot\nShutdown" | wofi --dmenu --prompt "Power Menu" | xargs -I {} sh -c 'case {} in Lock) swaylock;; Logout) loginctl terminate-session "$XDG_SESSION_ID";; Suspend) systemctl suspend;; Reboot) systemctl reboot;; Shutdown) systemctl poweroff;; esac']]))
      hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"))

      -- Focus / move / resize windows (arrow keys and hjkl share one table)
      local dirs = {
        { keys = { "left", "H" },  dir = "left",  x = -20, y = 0 },
        { keys = { "right", "L" }, dir = "right", x = 20,  y = 0 },
        { keys = { "up", "K" },    dir = "up",    x = 0,   y = -20 },
        { keys = { "down", "J" },  dir = "down",  x = 0,   y = 20 },
      }
      for _, d in ipairs(dirs) do
        for _, k in ipairs(d.keys) do
          hl.bind(mainMod .. " + " .. k,         hl.dsp.focus({ direction = d.dir }))
          hl.bind(mainMod .. " + SHIFT + " .. k, hl.dsp.window.move({ direction = d.dir }))
          hl.bind(mainMod .. " + CTRL + " .. k,  hl.dsp.window.resize({ x = d.x, y = d.y, relative = true }))
        end
      end

      -- Switch to / move window to workspaces 1-9
      for i = 1, 9 do
        hl.bind(mainMod .. " + " .. i,         hl.dsp.focus({ workspace = i }))
        hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i, silent = true }))
      end

      -- Scroll through workspaces
      hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
      hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

      -- Move/resize windows with mainMod + LMB/RMB drag
      hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
      hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

      -- Media keys
      hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("vol --up"),   { locked = true, repeating = true })
      hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("vol --down"), { locked = true, repeating = true })
      hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("bri --up"),   { locked = true, repeating = true })
      hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("bri --down"), { locked = true, repeating = true })
      hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
      hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
      hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"),       { locked = true })
      hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

      -- Window rules: apply a shared rule template to every pattern in a list,
      -- keyed by either `class` or `title`. Shallow-copies the template per
      -- call so hl.window_rule can't mutate the shared table.
      local function apply_rules(matchKey, patterns, rule)
        for _, p in ipairs(patterns) do
          local r = { match = { [matchKey] = p } }
          for k, v in pairs(rule) do r[k] = v end
          hl.window_rule(r)
        end
      end

      -- Float + 45% size + center
      apply_rules("class", {
        [[^(\.?blueman-manager.*)$]],
        [[^(pavucontrol)$]],
        [[^(org.pulseaudio.pavucontrol)$]],
        [[^(nm-connection-editor)$]],
      }, { float = true, size = "45% 45%", center = true })

      -- Float only
      apply_rules("class", {
        [[^(blueberry\.py)$]],
        [[^(steam)$]],
        [[^(guifetch)$]],
      }, { float = true })

      -- Tiling
      hl.window_rule({ match = { class = [[^dev\.warp\.Warp$]] }, tile = true })

      -- Picture-in-Picture
      hl.window_rule({
        match = { title = [[^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$]] },
        float = true, keep_aspect_ratio = true, move = "73% 72%", size = "25% 25%", pin = true,
      })

      -- Dialog windows: float + center
      apply_rules("title", {
        [[^(Open File)(.*)$]], [[^(Select a File)(.*)$]], [[^(Choose wallpaper)(.*)$]],
        [[^(Open Folder)(.*)$]], [[^(Save As)(.*)$]], [[^(Library)(.*)$]], [[^(File Upload)(.*)$]],
      }, { float = true, center = true })
    '';
  };
}
