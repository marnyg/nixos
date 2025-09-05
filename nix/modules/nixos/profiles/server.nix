# Server system profile
{ lib, pkgs, ... }:

{
  # No GUI
  services.xserver.enable = false;

  # SSH is essential for servers
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = lib.mkDefault "prohibit-password";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
    openFirewall = true;
  };

  # Automatic security updates
  system.autoUpgrade = {
    enable = lib.mkDefault true;
    allowReboot = lib.mkDefault false;
    dates = "04:00";
  };

  # Firewall
  networking.firewall = {
    enable = true;
    logRefusedConnections = false;
  };

  # Basic monitoring
  services.netdata.enable = lib.mkDefault true;

  # Fail2ban for SSH protection
  services.fail2ban = {
    enable = lib.mkDefault true;
    maxretry = 5;
  };

  # System hardening
  security.sudo.wheelNeedsPassword = true;

  # Disable unnecessary services
  services.avahi.enable = false;
  services.printing.enable = false;

  # Performance tuning
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  # Common server packages
  environment.systemPackages = with pkgs; [
    htop
    iotop
    iftop
    ncdu
    tmux
    vim
  ];
}
