{ pkgs, lib, config, ... }:
with lib;
{
  options.modules.hyperland = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.hyperland.enable {


    modules.wofi.enable = true;
    modules.waybar.enable = true;
    programs.waybar.systemd.enable = true;
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
    #wayland.windowManager.hyprland.enableNvidiaPatches = true;
    wayland.windowManager.hyprland.extraConfig = mkOrder 100 ''
      # See https://wiki.hyprland.org/Configuring/Keywords/ for more
      $mainMod = ALT

      # Swee https://wiki.hyprland.org/Configuring/Monitors/
      monitor=HDMI-A-1,3840x2160@120,1080x0,1.0
      monitor=HDMI-A-3,1920x1080@60.00Hz,0x0,1, transform,3
      #monitor=HDMI-A-1,2560x1440@60,0x0,1.0
      #monitor=HDMI-A-1,1920x1080@120,0x0,1.0

      #bind = $mainMod CTRL, 2, exec,hyprctl keyword monitor "HDMI-A-1,2560x1440@60,0x0,1.0" && hyprctl keyword monitor "HDMI-A-1,2560x1440@120,0x0,1.0"
      #bind = $mainMod CTRL, 1, exec,hyprctl keyword monitor "HDMI-A-1,1920x1080@120,0x0,1.0" && hyprctl keyword monitor "HDMI-A-1,1920x1080@120,0x0,1.0"

      #monitor=,preferred,auto,1.0
      #monitor=DP-3,2560x1440@59.951,3840x0,1,transform,1
      #exec-once = waybar & hyprpaper 
      exec-once = hyprctl setcursor cursor_theme cursor_size
      # Source a file (multi-file configs)
      # source = ~/.config/hypr/myColors.conf

      # Some default env vars.
      env = XCURSOR_SIZE,14
      #env = GTK_THEME,Nordic
      env = XCURSOR_THEME,Nordzy
      #env = GDK_BACKEND=wayland,x11
      env = CLUTTER_BACKEND=wayland
      env = XDG_CURRENT_DESKTOP=Hyprland
      env = XDG_SESSION_TYPE=wayland
      env = XDG_SESSION_DESKTOP=Hyprland
      env = QT_QPA_PLATFORM=wayland;xcb
      env = LIBVA_DRIVER_NAME,nvidia
      env = XDG_SESSION_TYPE,wayland
      #env = GBM_BACKEND,nvidia-drm
      env = __GLX_VENDOR_LIBRARY_NAME,nvidia
      env = WLR_NO_HARDWARE_CURSORS,1

      input {
          kb_layout = us
          #kb_variant = intl
          kb_model =
          kb_options = caps:escape
          kb_rules = 
          numlock_by_default = true
          follow_mouse = 0

          touchpad {
              natural_scroll = no
          }

          sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
      }

      general {

          gaps_in = 3
          gaps_out = 5
          border_size = 2
          col.active_border = rgb(5e81ac) rgb(5e81ac) 45deg
          col.inactive_border = rgba(595959aa)

          layout = dwindle
      }

      decoration {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more

          rounding = 3 

          #drop_shadow = yes
          #shadow_range = 4
          #shadow_render_power = 3
          #col.shadow = rgba(1a1a1aee)
      }

      animations {
          enabled = no
          #enabled = yes

          bezier = myBezier, 0.05, 0.9, 0.1, 1.05

          animation = windows, 1, 4, myBezier
          animation = windowsOut, 1, 4, default, popin 80%
          animation = border, 1, 10, default
          animation = borderangle, 1, 8, default
          animation = fade, 1, 7, default
          animation = workspaces, 1, 2, default
      }

      dwindle {
          pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
          preserve_split = yes # you probably want this
          force_split = 1
      }

      master {
          # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
          #new_is_master = true
      }

      gestures {
          workspace_swipe = off
      }

      #device:epic-mouse-v1 {
      #    sensitivity = -0.5
      #}

      # Example windowrule v1
      # windowrule = float, ^(kitty)$
      # Example windowrule v2
      # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
      # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more



      bind = $mainMod, W, exec, firefox 
      bind = $mainMod, return, exec, ghostty
      # bind = $mainMod, return, exec, foot 
      bindr = $mainMod, Q, killactive, 
      bind = $mainMod, M, exit, 
      bind = $mainMod, V, togglefloating, 
      bind = $mainMod, F, fullscreen, 
      # bind = $mainMod, D, pseudo, # dwindle
      bind = $mainMod, S, togglesplit, # dwindle

      ## FOCUS WINDOW
      bind = $mainMod, left, movefocus, l
      bind = $mainMod, right, movefocus, r
      bind = $mainMod, up, movefocus, u
      bind = $mainMod, down, movefocus, d
      bind = $mainMod, H, movefocus, l
      bind = $mainMod, L, movefocus, r
      bind = $mainMod, K, movefocus, u
      bind = $mainMod, J, movefocus, d

      ## MOVE WINDOW
      bind = $mainMod SHIFT, left, movewindow, l
      bind = $mainMod SHIFT, right, movewindow, r
      bind = $mainMod SHIFT, up, movewindow, u
      bind = $mainMod SHIFT, down, movewindow, d
      bind = $mainMod SHIFT, H, movewindow, l
      bind = $mainMod SHIFT, L, movewindow, r
      bind = $mainMod SHIFT, K, movewindow, u
      bind = $mainMod SHIFT, J, movewindow, d
                
      ## REZISE WINDOW 
      bind = $mainMod CTRL, left, resizeactive, -20 0
      bind = $mainMod CTRL, right, resizeactive, 20 0
      bind = $mainMod CTRL, up, resizeactive, 0 -20
      bind = $mainMod CTRL, down, resizeactive, 0 20
      bind = $mainMod CTRL, H, resizeactive, -20 0
      bind = $mainMod CTRL, L, resizeactive, 20 0
      bind = $mainMod CTRL, K, resizeactive, 0 -20
      bind = $mainMod CTRL, J, resizeactive, 0 20



      # Switch workspaces with mainMod + [0-9]
      bind = $mainMod, 1, workspace, 1
      bind = $mainMod, 2, workspace, 2
      bind = $mainMod, 3, workspace, 3
      bind = $mainMod, 4, workspace, 4
      bind = $mainMod, 5, workspace, 5
      bind = $mainMod, 6, workspace, 6
      bind = $mainMod, 7, workspace, 7
      bind = $mainMod, 8, workspace, 8
      bind = $mainMod, 9, workspace, 9

      # Move active window to a workspace with mainMod + SHIFT + [0-9]
      bind = $mainMod SHIFT, 1, movetoworkspacesilent, 1
      bind = $mainMod SHIFT, 2, movetoworkspacesilent, 2
      bind = $mainMod SHIFT, 3, movetoworkspacesilent, 3
      bind = $mainMod SHIFT, 4, movetoworkspacesilent, 4
      bind = $mainMod SHIFT, 5, movetoworkspacesilent, 5
      bind = $mainMod SHIFT, 6, movetoworkspacesilent, 6
      bind = $mainMod SHIFT, 7, movetoworkspacesilent, 7
      bind = $mainMod SHIFT, 8, movetoworkspacesilent, 8
      bind = $mainMod SHIFT, 9, movetoworkspacesilent, 9

      # Scroll through existing workspaces with mainMod + scroll
      bind = $mainMod, mouse_down, workspace, e+1
      bind = $mainMod, mouse_up, workspace, e-1

      # Move/resize windows with mainMod + LMB/RB and dragging
      bindm = $mainMod, mouse:272, movewindow
      bindm = $mainMod, mouse:273, resizewindow

      # Media keys
      bind=, , exec, vol --up
      bindle=, XF86AudioRaiseVolume, exec, vol --up
      bindle=, XF86AudioLowerVolume, exec, vol --down
      bindle=, XF86MonBrightnessUp, exec, bri --up
      bindle=, XF86MonBrightnessDown, exec, bri --down
      # bindl=, XF86AudioMute, exec, amixer set Master toggle
      bindl=, XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      bindl=, XF86AudioPlay, exec, playerctl play-pause # the stupid key is called play , but it toggles 
      bindl=, XF86AudioNext, exec, playerctl next 
      bindl=, XF86AudioPrev, exec, playerctl previous

      ## RULES 
      # Floating
      windowrulev2 = float, class:^(blueberry\.py)$
      windowrulev2 = float, class:^(steam)$
      windowrulev2 = float, class:^(guifetch)$   # FlafyDev/guifetch
      windowrulev2 = float, class:^(pavucontrol)$
      windowrulev2 = size 45%, class:^(pavucontrol)$
      windowrulev2 = center, class:^(pavucontrol)$
      windowrulev2 = float, class:^(org.pulseaudio.pavucontrol)$
      windowrulev2 = size 45%, class:^(org.pulseaudio.pavucontrol)$
      windowrulev2 = center, class:^(org.pulseaudio.pavucontrol)$
      windowrulev2 = float, class:^(nm-connection-editor)$
      windowrulev2 = size 45%, class:^(nm-connection-editor)$
      windowrulev2 = center, class:^(nm-connection-editor)$

      # Tiling
      windowrulev2 = tile, class:^dev\.warp\.Warp$

      # Picture-in-Picture
      windowrulev2 = float, title:^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$
      windowrulev2 = keepaspectratio, title:^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$
      windowrulev2 = move 73% 72%, title:^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$ 
      windowrulev2 = size 25%, title:^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$
      windowrulev2 = float, title:^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$
      windowrulev2 = pin, title:^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$

      # Dialog windows – float+center these windows.
      windowrulev2 = center, title:^(Open File)(.*)$
      windowrulev2 = center, title:^(Select a File)(.*)$
      windowrulev2 = center, title:^(Choose wallpaper)(.*)$
      windowrulev2 = center, title:^(Open Folder)(.*)$
      windowrulev2 = center, title:^(Save As)(.*)$
      windowrulev2 = center, title:^(Library)(.*)$
      windowrulev2 = center, title:^(File Upload)(.*)$
      windowrulev2 = float, title:^(Open File)(.*)$
      windowrulev2 = float, title:^(Select a File)(.*)$
      windowrulev2 = float, title:^(Choose wallpaper)(.*)$
      windowrulev2 = float, title:^(Open Folder)(.*)$
      windowrulev2 = float, title:^(Save As)(.*)$
      windowrulev2 = float, title:^(Library)(.*)$
      windowrulev2 = float, title:^(File Upload)(.*)$

      #windowrule = float, file_progress
      #windowrule = float, confirm
      #windowrule = float, dialog
      #windowrule = float, download
      #windowrule = float, notification
      #windowrule = float, error
      #windowrule = float, splash
      #windowrule = float, confirmreset
      #windowrule = float, title:Open File
      #windowrule = float, title:branchdialog
      #windowrule = float, Lxappearance
      #windowrule = float, Rofi
      #windowrule = animation none,Rofi
      #windowrule = float,viewnior
      #windowrule = float,feh
      #windowrule = float, pavucontrol-qt
      #windowrule = float, pavucontrol
      #windowrule = float, file-roller
      #windowrule = fullscreen, wlogout
      #windowrule = float, title:wlogout
      #windowrule = fullscreen, title:wlogout
      #windowrule = idleinhibit focus, mpv
      #windowrule = idleinhibit fullscreen, firefox
      #windowrule = float, title:^(Media viewer)$
      #windowrule = float, title:^(Volume Control)$
      #windowrule = float, title:^(Picture-in-Picture)$
      #windowrule = size 800 600, title:^(Volume Control)$
      #windowrule = move 75 44%, title:^(Volume Control)$


      # trigger when the switch is turning off
      #bindl = , switch:off:Lid Switch,exec,hyprctl keyword monitor "eDP-1, 1920x1080, 0x0, 1"
      # trigger when the switch is turning on
      #bindl = , switch:on:Lid Switch,exec,hyprctl keyword monitor "eDP-1, disable"

    '';
  };
}
