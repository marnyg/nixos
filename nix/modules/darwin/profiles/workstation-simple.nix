# Darwin workstation profile (simplified)
# Configures a full-featured macOS development workstation
{ pkgs, lib, ... }:
{
  # Import core modules
  imports = [
    ../core/defaults.nix
    ../core/nix-settings.nix # Now optimized for macOS performance
    ../core/fonts.nix
  ];

  # Yabai window manager
  services.yabai = {
    enable = true;
    enableScriptingAddition = true;
    config.layout = "bsp";
    extraConfig = ''
      # System app rules
      yabai -m rule --add app="^System Settings$"    manage=off
      yabai -m rule --add app="^System Information$" manage=off
      yabai -m rule --add app="^System Preferences$" manage=off
      yabai -m rule --add title="Preferences$"       manage=off
      yabai -m rule --add title="Settings$"          manage=off
      
      # Workspace management
      yabai -m space 1  --label todo
      yabai -m space 2  --label code
      yabai -m space 3  --label productive
      yabai -m space 4  --label utils
      yabai -m space 5  --label chat
      
      # App assignments
      yabai -m rule --add app="Reminder" space=todo
      yabai -m rule --add app="Mail" space=todo
      yabai -m rule --add app="Calendar" space=todo
      
      yabai -m rule --add app="Visual Studio Code" space=code
      yabai -m rule --add app="IntelliJ IDEA" space=code
      yabai -m rule --add app="Xcode" space=code
      
      yabai -m rule --add app="Alacritty" space=productive
      yabai -m rule --add app="Arc" space=productive
      yabai -m rule --add app="Safari" space=productive
      yabai -m rule --add app="Firefox" space=productive
      
      yabai -m rule --add app="Spotify" space=utils
      yabai -m rule --add app="Music" space=utils
      yabai -m rule --add app="Finder" space=utils
      
      yabai -m rule --add app="Microsoft Teams" space=chat
      yabai -m rule --add app="Slack" space=chat
      yabai -m rule --add app="Signal" space=chat
      yabai -m rule --add app="Messages" space=chat
      yabai -m rule --add app="Discord" space=chat
    '';
  };

  # skhd hotkey daemon
  services.skhd = {
    enable = true;
    skhdConfig = ''
      # Reload config
      alt - r : yabai -m rule --apply; launchctl stop org.nixos.skhd; launchctl start org.nixos.skhd; launchctl stop org.nixos.yabai; launchctl start org.nixos.yabai
      
      # Open apps
      alt - return : sh -c 'open ~/Applications/Home\ Manager\ Trampolines/Ghostty.app/'
      alt - f : sh -c 'open ~/Applications/Home\ Manager\ Trampolines/Firefox.app/'
      
      # Window focus navigation
      alt - h : sh -c "yabai -m window --focus west || yabai -m display --focus west"
      alt - j : sh -c "yabai -m window --focus south || yabai -m display --focus south"
      alt - k : sh -c "yabai -m window --focus north || yabai -m display --focus north"
      alt - l : sh -c "yabai -m window --focus east || yabai -m display --focus east"
      
      # Stack navigation
      alt - p : yabai -m window --focus stack.prev || yabai -m window --focus stack.last
      alt - n : yabai -m window --focus stack.next || yabai -m window --focus stack.first
      
      # Layout management
      alt - d : sh -c "yabai -m space --layout $(yabai -m query --spaces --space | jq -r 'if .type == \"bsp\" then \"stack\" else \"bsp\" end')"
      alt - t : yabai -m window --toggle float
      alt - m : yabai -m window --toggle zoom-fullscreen
      
      # Disable cmd-h hide
      cmd - h : echo "no hide window"
    '';
  };

  # Tailscale VPN
  services.tailscale.enable = true;

  # Additional system packages
  environment.systemPackages = with pkgs; [
    terminal-notifier
    mas # Mac App Store CLI
    cocoapods
  ];

  # Enable specific shells
  environment.shells = [ pkgs.fish pkgs.zsh pkgs.bash ];

  # User configuration
  system.primaryUser = lib.mkDefault "mariusnygard";
}
