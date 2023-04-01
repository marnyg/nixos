{ pkgs, lib, config, ... }:
with lib;
{
  options.modules.dunst = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.dunst.enable {
    home.file = {
      ".config/dunst/dunstrc" = {
        source = ./dunstrc;
        target = ".config/dunst/dunstrc2";
      };
    };

    services.dunst = {
      # configFile = "${config.xdg.configHome}/dunst/dunstrc2";
      enable = true;
      settings = {
        # global = {
        #   width = 300;
        #   height = 300;
        #   offset = "30x50";
        #   origin = "top-right";
        #   transparency = 10;
        #   frame_color = "#eceff1";
        #   font = "Droid Sans 9";
        # };
        shortcuts = {
          close = "ctrl+q";
          close_all = "ctrl+shift+q";
        };

        urgency_low = {
          background = "#282a36";
          foreground = "#6272a4";
          timeout = 10;
        };
        urgency_normal = {
          background = "#282a36";
          foreground = "#bd93f9";
          timeout = 10;
        };
        urgency_critical = {
          background = "#ff5555";
          foreground = "#f8f8f2";
          frame_color = "#ff5555";
          timeout = 0;
        };
        global = {
          font = "Iosevka Term 11";
          # Allow a small subset of html markup:
          #   <b>bold</b>
          #   <i>italic</i>
          #   <s>strikethrough</s>
          #   <u>underline</u>
          #
          # For a complete reference see
          # <http://developer.gnome.org/pango/stable/PangoMarkupFormat.html>.
          # If markup is not allowed, those tags will be stripped out of the
          # message.
          markup = "yes";
          plain_text = "no";
          # The format of the message.  Possible variables are:
          #   %a  appname
          #   %s  summary
          #   %b  body
          #   %i  iconname (including its path)
          #   %I  iconname (without its path)
          #   %p  progress value if set ([  0%] to [100%]) or nothing
          # Markup is allowed
          format = ''
            %a
            <b>%s</b>
            %b'';
          # Sort messages by urgency.
          sort = "yes";
          # Show how many messages are currently hidden (because of geometry).
          indicate_hidden = "yes";
          # Alignment of message text.
          # Possible values are "left", "center" and "right".
          alignment = "center";
          # The frequency with wich text that is longer than the notification
          # window allows bounces back and forth.
          # This option conflicts with "word_wrap".
          # Set to 0 to disable.
          bounce_freq = 0;
          # Show age of message if message is older than show_age_threshold
          # seconds.
          # Set to -1 to disable.
          show_age_threshold = 1;
          # Split notifications into multiple lines if they don't fit into
          # geometry.
          word_wrap = "yes";
          # Ignore newlines '\n' in notifications.
          ignore_newline = "no";
          # Hide duplicate's count and stack them
          stack_duplicates = "yes";
          hide_duplicates_count = "no";
          # The geometry of the window:
          #   [{width}]x{height}[+/-{x}+/-{y}]
          # The geometry of the message window.
          # The height is measured in number of notifications everything else
          # in pixels.  If the width is omitted but the height is given
          # ("-geometry x2"), the message window expands over the whole screen
          # (dmenu-like).  If width is 0, the window expands to the longest
          # message displayed.  A positive x is measured from the left, a
          # negative from the right side of the screen.  Y is measured from
          # the top and down respectevly.
          # The width can be negative.  In this case the actual width is the
          # screen width minus the width defined in within the geometry option.
          geometry = "500x10-0+0";
          # Shrink window if it's smaller than the width.  Will be ignored if
          # width is 0.
          shrink = "no";
          # Don't remove messages, if the user is idle (no mouse or keyboard input)
          # for longer than idle_threshold seconds.
          # Set to 0 to disable.
          idle_threshold = 0;
          # The transparency of the window.  Range: [0; 100].
          # This option will only work if a compositing windowmanager is
          # present (e.g. xcompmgr, compiz, etc.).
          # transparency = 5
          # Which monitor should the notifications be displayed on.
          #monitor = keyboard
          # Display notification on focused monitor.  Possible modes are:
          #   mouse: follow mouse pointer
          #   keyboard: follow window with keyboard focus
          #   none: don't follow anything
          #
          # "keyboard" needs a windowmanager that exports the
          # _NET_ACTIVE_WINDOW property.
          # This should be the case for almost all modern windowmanagers.
          #
          # If this option is set to mouse or keyboard, the monitor option
          # will be ignored.
          follow = "none";
          # Should a notification popped up from history be sticky or timeout
          # as if it would normally do.
          sticky_history = "yes";
          # Maximum amount of notifications kept in history
          history_length = 15;
          # Display indicators for URLs (U) and actions (A).
          show_indicators = "no";
          # The height of a single line.  If the height is smaller than the
          # font height, it will get raised to the font height.
          # This adds empty space above and under the text.
          line_height = 3;
          # Draw a line of "separatpr_height" pixel height between two
          # notifications.
          # Set to 0 to disable.
          separator_height = 1;
          # Padding between text and separator.
          padding = 8;
          # Horizontal padding.
          horizontal_padding = 10;
          # Define a color for the separator.
          # possible values are:
          #  * auto: dunst tries to find a color fitting to the background;
          #  * foreground: use the same color as the foreground;
          #  * frame: use the same color as the frame;
          #  * anything else will be interpreted as a X color.
          separator_color = "frame";
          # Print a notification on startup.
          # This is mainly for error detection, since dbus (re-)starts dunst
          # automatically after a crash.
          startup_notification = true;
          # dmenu path.
          dmenu = "${pkgs.dmenu}/bin/dmenu -p dunst:";
          # Browser for opening urls in context menu.
          # browser = /usr/bin/firefox -new-tab
          # Align icons left/right/off
          # icon_position = "off";
          max_icon_size = 80;
          frame_width = 2;
          frame_color = "#282a36";
          mouse_left_click = "close_current";
          mouse_middle_click = "do_action, close_current";
          mouse_right_click = "close_all";
          progress_bar = true;

          # Set the progress bar height. This includes the frame, so make sure
          # it's at least twice as big as the frame width.
          progress_bar_height = 10;

          # Set the frame width of the progress bar
          progress_bar_frame_width = 1;

          # Set the minimum width for the progress bar
          progress_bar_min_width = 150;

          # Set the maximum width for the progress bar
          progress_bar_max_width = 300;
          # transparency = 10;

          #  text= (builtins.readFile ./dunstrc);
        };
      };
    };
  };
}
