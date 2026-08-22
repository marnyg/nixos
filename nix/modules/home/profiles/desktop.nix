# Desktop profile - GUI applications and desktop environment configurations
{ lib, pkgs, ... }:
let
  # Flameshot-style screenshot "applet": a wofi menu offering region/window/
  # monitor/full capture, routed through grim + satty (annotation editor).
  # hyprctl is provided by the running Hyprland session's PATH.
  screenshot-menu = pkgs.writeShellApplication {
    name = "screenshot-menu";
    runtimeInputs = with pkgs; [ grim slurp satty wl-clipboard jq wofi libnotify ];
    text = ''
      dir="$HOME/Pictures/Screenshots"
      mkdir -p "$dir"
      file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"

      choice=$(printf '%s\n' \
        "Region -> annotate" \
        "Region -> clipboard" \
        "Region -> file" \
        "Window -> file" \
        "Monitor -> file" \
        "Full desktop -> file" \
        | wofi --dmenu --prompt "Screenshot")

      notify() { notify-send -t 2000 "Screenshot" "$1"; }

      case "$choice" in
        "Region -> annotate")
          grim -g "$(slurp)" - | satty --filename - --output-filename "$file" --early-exit --copy-command wl-copy ;;
        "Region -> clipboard")
          grim -g "$(slurp)" - | wl-copy && notify "region copied to clipboard" ;;
        "Region -> file")
          grim -g "$(slurp)" "$file" && notify "saved $file" ;;
        "Window -> file")
          geom=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
          grim -g "$geom" "$file" && notify "saved $file" ;;
        "Monitor -> file")
          grim -o "$(hyprctl monitors -j | jq -r '.[] | select(.focused).name')" "$file" && notify "saved $file" ;;
        "Full desktop -> file")
          grim "$file" && notify "saved $file" ;;
      esac
    '';
  };
in
{
  # Desktop modules
  modules.my = {
    # CORE: Essential for desktop profile
    firefox.enable = true; # Every desktop needs a web browser

    # OPTIONAL: Sensible defaults that can be overridden
    # Terminal emulators (at least one needed, but choice is flexible)
    ghostty.enable = lib.mkDefault true;
    kitty.enable = lib.mkDefault false;

    # Window managers (one should be active, but choice is flexible)
    bspwm.enable = lib.mkDefault false;
    xmonad.enable = lib.mkDefault false;
    hyprland.enable = lib.mkDefault true;

    # Desktop utilities (helpful but not essential)
    dunst.enable = lib.mkDefault false;
    waybar.enable = lib.mkDefault true; # Pairs with hyprland default
    quickshell.enable = lib.mkDefault false; # Alternative bar to waybar
    wofi.enable = lib.mkDefault true; # Pairs with hyprland default
    rofi.enable = lib.mkDefault false; # Alternative to wofi

    # Optional features
    qutebrowser.enable = lib.mkDefault false;
    spotifyd.enable = lib.mkDefault false;
  };

  # GUI programs
  programs = {
    # CORE: Essential GUI programs for desktop
    mpv.enable = true; # Video player is essential for desktop
    yazi.enable = true; # File manager is essential for desktop
    yazi.shellWrapperName = "y";

    # OPTIONAL: Nice to have but not essential
    ncspot.enable = lib.mkDefault false;
    spotify-player.enable = lib.mkDefault true;
    spotify-player.settings = {
      login_redirect_uri = "http://127.0.0.1:8988/login";
      enable_media_control = true;
      device.name = "marius-desktop-cli";
    };
  };

  # Desktop packages
  home.packages = with pkgs; [
    # GUI utilities
    xclip
    xsel
    wl-clipboard
    rofi
    dmenu
    feh
    sxiv
    xdotool
    scrot
    libnotify

    # Screenshot and clipboard utilities
    grim
    slurp
    satty # annotation editor (flameshot-like)
    jq # used by screenshot keybind to find focused monitor
    screenshot-menu # wofi-based screenshot applet (see let-binding above)
    cliphist
    clipmenu

    # Color pickers
    hyprpicker
    gpick

    # Lock screens
    swaylock
    i3lock

    # File management
    nautilus
    pcmanfm

    # Media
    vlc
    spotify
    mpv
    pavucontrol
    playerctl
    coppwr

    # Graphics
    gimp
    inkscape

    # Documents
    libreoffice
    evince # PDF viewer

    # Communication
    discord
    slack
    signal-desktop

    # Development GUIs
    claude-code
    terminal-browser # browser in the terminal (kitty graphics protocol)

    # Remote desktop
    tigervnc # VNC client (`vncviewer`)

    # Game development
    godot # Godot 4 (currently 4.6.3)

    # System utilities
    gnome-system-monitor
    baobab # Disk usage analyzer
    (crush.overrideAttrs (_: { doCheck = false; })) # Process manager - tests disabled due to flakiness

    # Fonts
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    source-code-pro
    roboto
    liberation_ttf
  ] ++ lib.optionals (pkgs.stdenv.isLinux && !pkgs.stdenv.isAarch64) [
    # Linux/X11 specific
    bitwarden-cli
  ];

  # Desktop-specific configuration
  home.sessionVariables = {
    BROWSER = "firefox";
  };

  # Font configuration
  fonts.fontconfig.enable = true;

  # GTK theme configuration
  gtk = {
    enable = true;
    gtk4.theme = null;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  # Qt theme configuration
  qt = {
    enable = true;
    # "gtk" was deprecated upstream; "gtk3" selects the modern native Qt
    # GTK3 plugin (use "gtk2" to keep the legacy qtstyleplugins behavior).
    platformTheme.name = "gtk3";
    style.name = "adwaita-dark";
  };
}
