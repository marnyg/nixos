# macOS system defaults module
# Provides configurable macOS system preferences with sensible defaults
{ lib, config, ... }:

let
  cfg = config.modules.darwin.defaults;
in
{
  options.modules.darwin.defaults = {
    enable = lib.mkEnableOption "macOS system defaults";

    darkMode = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable dark mode interface";
    };

    naturalScrolling = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable natural scrolling direction";
    };

    dockAutohide = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Automatically hide and show the dock";
    };

    keyRepeat = {
      initial = lib.mkOption {
        type = lib.types.int;
        default = 15;
        description = "Initial key repeat delay";
      };
      rate = lib.mkOption {
        type = lib.types.int;
        default = 2;
        description = "Key repeat rate";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # System state version
    system.stateVersion = 6;

    # Basic shell support
    programs.zsh.enable = true;
    programs.fish.enable = true;

    # macOS system defaults
    system.defaults = {
      # Dock settings
      dock = {
        autohide = cfg.dockAutohide;
        show-recents = lib.mkDefault false;
        tilesize = lib.mkDefault 48;
        minimize-to-application = lib.mkDefault true;
      };

      # Finder settings
      finder = {
        AppleShowAllExtensions = true;
        _FXShowPosixPathInTitle = true;
        FXEnableExtensionChangeWarning = false;
        ShowPathbar = lib.mkDefault true;
        ShowStatusBar = lib.mkDefault true;
      };

      # Screenshot settings
      screencapture.location = lib.mkDefault "/tmp";

      # Window Manager
      WindowManager.EnableStandardClickToShowDesktop = false;

      # Global domain settings
      NSGlobalDomain = {
        # Disable natural scrolling
        "com.apple.swipescrolldirection" = cfg.naturalScrolling;

        # Menu bar settings
        _HIHideMenuBar = lib.mkDefault false;

        # Keyboard settings
        InitialKeyRepeat = cfg.keyRepeat.initial;
        KeyRepeat = cfg.keyRepeat.rate;

        # Show all file extensions
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;

        # Dark mode
        AppleInterfaceStyle = if cfg.darkMode then "Dark" else null;

        # Expand save panel by default
        NSNavPanelExpandedStateForSaveMode = lib.mkDefault true;
        NSNavPanelExpandedStateForSaveMode2 = lib.mkDefault true;

        # Disable automatic capitalization and smart quotes
        NSAutomaticCapitalizationEnabled = lib.mkDefault false;
        NSAutomaticDashSubstitutionEnabled = lib.mkDefault false;
        NSAutomaticPeriodSubstitutionEnabled = lib.mkDefault false;
        NSAutomaticQuoteSubstitutionEnabled = lib.mkDefault false;
        NSAutomaticSpellingCorrectionEnabled = lib.mkDefault false;
      };
    };

    # TouchID for sudo
    security.pam.services.sudo_local.touchIdAuth = lib.mkDefault true;
  };
}
