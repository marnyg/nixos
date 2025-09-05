# Desktop profile - GUI applications and desktop environment configurations
{ lib, pkgs, ... }:

{
  # Desktop modules
  modules = {
    # Browsers
    firefox.enable = true;
    qutebrowser.enable = lib.mkDefault false;

    # Terminal emulators
    ghostty.enable = lib.mkDefault true;
    kitty.enable = lib.mkDefault false;

    # Window managers (choose one)
    bspwm.enable = lib.mkDefault false;
    xmonad.enable = lib.mkDefault false;
    hyperland.enable = lib.mkDefault true;

    # Desktop utilities
    dunst.enable = lib.mkDefault false;
    polybar.enable = lib.mkDefault false;
    waybar.enable = lib.mkDefault true;
    wofi.enable = lib.mkDefault true;

    # Media
    spotifyd.enable = lib.mkDefault false;
  };

  # GUI programs
  programs = {
    # Media players
    mpv.enable = true;
    ncspot.enable = lib.mkDefault true;

    # File managers
    yazi.enable = true;
  };

  # Desktop packages
  home.packages = with pkgs; [
    # GUI utilities
    xclip
    xsel
    wl-clipboard
    flameshot

    # File management
    nautilus
    pcmanfm

    # Media
    vlc
    spotify
    pavucontrol

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

    # System utilities
    gnome-system-monitor
    baobab # Disk usage analyzer

    # Fonts
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    source-code-pro
    roboto
    liberation_ttf
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
    platformTheme.name = "gtk";
    style.name = "adwaita-dark";
  };
}
