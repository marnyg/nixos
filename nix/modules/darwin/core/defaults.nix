# macOS system defaults module
{ lib, ... }:
{
  # System state version
  system.stateVersion = 6;

  # Basic shell support
  programs.zsh.enable = true;
  programs.fish.enable = true;

  # macOS system defaults
  system.defaults = {
    # Dock settings
    dock = {
      autohide = lib.mkDefault true;
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
      "com.apple.swipescrolldirection" = lib.mkDefault false;

      # Menu bar settings
      _HIHideMenuBar = lib.mkDefault false;

      # Keyboard settings
      InitialKeyRepeat = lib.mkDefault 15;
      KeyRepeat = lib.mkDefault 2;

      # Show all file extensions
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;

      # Dark mode
      AppleInterfaceStyle = lib.mkDefault "Dark";

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
}
