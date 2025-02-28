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
    experimental-features = nix-command flakes
  '' + lib.optionalString (pkgs.system == "aarch64-darwin") ''
    extra-platforms = x86_64-darwin aarch64-darwin
  '';

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true;
  # users.users.mariusnygard.shell = pkgs.nushell;


  # Apps
  # `home-manager` currently has issues adding them to `~/Applications`
  # Issue: https://github.com/nix-community/home-manager/issues/1341
  environment.systemPackages = with pkgs; [
    terminal-notifier
  ];

  system.defaults.NSGlobalDomain."com.apple.swipescrolldirection" = false;
  system.defaults.NSGlobalDomain.InitialKeyRepeat = 15;
  system.defaults.NSGlobalDomain.KeyRepeat = 2;
  system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;
  system.defaults.NSGlobalDomain.AppleShowAllFiles = true;
  system.defaults.NSGlobalDomain.AppleInterfaceStyle = "Dark";
  system.defaults.WindowManager.EnableStandardClickToShowDesktop = false;

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
      # alt + a / u / o / s are blocked due to umlaute

      # Reload config
      alt - r : yabai -m rule --apply; launchctl stop org.nixos.skhd; launchctl start org.nixos.skhd; launchctl stop org.nixos.yabai; launchctl start org.nixos.yabai

      # Open apps
      alt - return : kitty -d ~
      alt - f : open /Applications/Firefox.app

      # move window focus

      alt - h : yabai -m window --focus west || yabai -m display --focus west
      alt - j : yabai -m window --focus south || yabai -m display --focus south
      alt - k : yabai -m window --focus north || yabai -m display --focus north
      alt - l : yabai -m window --focus east || yabai -m display --focus east

      # swap managed window
      shift + alt - h : yabai -m window --swap west || $(yabai -m window --display west; yabai -m display --focus west)
      shift + alt - j : yabai -m window --swap south || $(yabai -m window --display south; yabai -m display --focus south)
      shift + alt - k : yabai -m window --swap north || $(yabai -m window --display north; yabai -m display --focus north)
      shift + alt - l : yabai -m window --swap east || $(yabai -m window --display east; yabai -m display --focus east)

      alt - 1 : yabai -m space --focus 1
      alt - 2 : yabai -m space --focus 2
      alt - 3 : yabai -m space --focus 3
      alt - 4 : yabai -m space --focus 4
      alt - 5 : yabai -m space --focus 5
      shift + alt - 1 : yabai -m window --space 1
      shift + alt - 2 : yabai -m window --space 2
      shift + alt - 3 : yabai -m window --space 3
      shift + alt - 4 : yabai -m window --space 4
      shift + alt - 5 : yabai -m window --space 5

      # toggle layout
      alt - d : yabai -m space --layout $(yabai -m query --spaces --space | jq -r 'if .type == "bsp" then "stack" else "bsp" end')
    '';
  };
  # Keyboard
  #system.keyboard.enableKeyMapping = true;
  #system.keyboard.remapCapsLockToEscape = true;

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;
}
