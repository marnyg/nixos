# Font configuration for macOS
{ pkgs, lib, ... }:
{
  fonts.packages = lib.mkDefault [
    # Nerd fonts
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts._0xproto
    pkgs.nerd-fonts.droid-sans-mono
    # pkgs.nerd-fonts.jetbrains-mono  # Disabled - build deps fail on Darwin
    pkgs.nerd-fonts.hack

    # Regular fonts
    pkgs.fira-code
    # pkgs.jetbrains-mono  # Disabled - Python test failures in build deps
    pkgs.fira-code-symbols
    pkgs.source-code-pro
    pkgs.inconsolata
  ];
}
