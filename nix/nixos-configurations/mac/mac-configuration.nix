{ pkgs, lib, ... }:
{
  # Nix configuration ------------------------------------------------------------------------------
  system.stateVersion = 6;

  nix.settings.substituters = [ "https://cache.nixos.org/" ];
  nix.settings.trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
  nix.settings.trusted-users = [ "@admin" ];
  nix.enable = true;

  # Enable experimental nix command and flakes
  # nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    auto-optimise-store = true
    download-buffer-size = 268435456
    experimental-features = nix-command flakes
  '' + lib.optionalString (pkgs.system == "aarch64-darwin") ''
    extra-platforms = x86_64-darwin aarch64-darwin
  '';

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true;
  users.users.mariusnygard.shell = lib.mkForce pkgs.fish;
  programs.fish.enable = true;
  environment.shells = [ pkgs.fish ];

  services.tailscale.enable = true;


  fonts.packages = [
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts._0xproto
    pkgs.nerd-fonts.droid-sans-mono
    pkgs.fira-code
    pkgs.jetbrains-mono
    pkgs.fira-code-symbols
  ];

  # Apps
  # `home-manager` currently has issues adding them to `~/Applications`
  # Issue: https://github.com/nix-community/home-manager/issues/1341
  environment.systemPackages = with pkgs; [
    terminal-notifier
  ];

  system.defaults = {

    dock = {
      autohide = true;
      # orientation = "right";
    };

    finder = {
      AppleShowAllExtensions = true;
      _FXShowPosixPathInTitle = true;
      FXEnableExtensionChangeWarning = false;
    };

    screencapture.location = "/tmp";

    WindowManager.EnableStandardClickToShowDesktop = false;
    NSGlobalDomain = {
      "com.apple.swipescrolldirection" = false;
      _HIHideMenuBar = false;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      AppleInterfaceStyle = "Dark";
    };
  };

  services.yabai.enable = true;
  services.yabai.enableScriptingAddition = true;
  services.yabai.config.layout = "bsp";
  services.yabai.extraConfig = ''
    # rules
    yabai -m rule --add app="^System Settings$"    manage=off
    yabai -m rule --add app="^System Information$" manage=off
    yabai -m rule --add app="^System Preferences$" manage=off
    yabai -m rule --add title="Preferences$"       manage=off
    yabai -m rule --add title="Settings$"          manage=off

    # workspace management
    yabai -m space 1  --label todo
    yabai -m space 2  --label code
    yabai -m space 3  --label productive
    yabai -m space 4  --label utils
    yabai -m space 5  --label chat

    # assign apps to spaces
    yabai -m rule --add app="Reminder" space=todo
    yabai -m rule --add app="Mail" space=todo
    yabai -m rule --add app="Calendar" space=todo

    yabai -m rule --add app="Alacritty" space=productive
    yabai -m rule --add app="Arc" space=productive

    yabai -m rule --add app="Microsoft Teams" space=chat
    yabai -m rule --add app="Microsoft Outlook" space=chat
    yabai -m rule --add app="Slack" space=chat
    œ
    yabai -m rule --add app="Signal" space=chat
    yabai -m rule --add app="Messages" space=chat

    yabai -m rule --add app="Spotify" space=utils
    yabai -m rule --add app="Ivanti Secure Access" space=utils

    yabai -m rule --add app="Visual Studio Code" space=code
    yabai -m rule --add app="IntelliJ IDEA" space=code

  '';
  services.skhd = {
    enable = true;
    skhdConfig = ''
      # Reload config
      alt - r : yabai -m rule --apply; launchctl stop org.nixos.skhd; launchctl start org.nixos.skhd; launchctl stop org.nixos.yabai; launchctl start org.nixos.yabai

      # Open apps
      alt - return : sh -c 'open ~/Applications/Home\ Manager\ Trampolines/Ghostty.app/'
      alt - f : sh -c 'open ~/Applications/Home\ Manager\ Trampolines/Firefox.app/'


      # move window focus (wrapped in sh -c for nushell compatability)
      alt - h : sh -c "yabai -m window --focus west || yabai -m display --focus west"
      alt - j : sh -c "yabai -m window --focus south || yabai -m display --focus south"
      alt - k : sh -c "yabai -m window --focus north || yabai -m display --focus north"
      alt - l : sh -c "yabai -m window --focus east || yabai -m display --focus east"

      alt - n : yabai -m window --focus stack.next || yabai -m window --focus next || yabai -m window --focus first
      alt - p : yabai -m window --focus stack.prev || yabai -m window --focus prev || yabai -m window --focus last

      # swap managed window (wrapped in sh -c for nushell compatability)
      # shift + alt - h : sh -c "yabai -m window --swap west || $(yabai -m window --display west; yabai -m display --focus west)"
      # shift + alt - j : sh -c "yabai -m window --swap south || $(yabai -m window --display south; yabai -m display --focus south)"
      # shift + alt - k : sh -c "yabai -m window --swap north || $(yabai -m window --display north; yabai -m display --focus north)"
      # shift + alt - l : sh -c "yabai -m window --swap east || $(yabai -m window --display east; yabai -m display --focus east)"

      # alt - 1 : yabai -m space --focus 1
      # alt - 2 : yabai -m space --focus 2
      # alt - 3 : yabai -m space --focus 3
      # alt - 4 : yabai -m space --focus 4
      # alt - 5 : yabai -m space --focus 5
      # shift + alt - 1 : yabai -m window --space 1
      # shift + alt - 2 : yabai -m window --space 2
      # shift + alt - 3 : yabai -m window --space 3
      # shift + alt - 4 : yabai -m window --space 4
      # shift + alt - 5 : yabai -m window --space 5

      # toggle layout
      alt - d : sh -c "yabai -m space --layout $(yabai -m query --spaces --space | jq -r 'if .type == "bsp" then "stack" else "bsp" end')"
      cmd - h : echo "no hide window"
    '';
  };
  # Keyboard
  #system.keyboard.enableKeyMapping = true;
  #system.keyboard.remapCapsLockToEscape = true;

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;
  system.primaryUser = "mariusnygard";
}
