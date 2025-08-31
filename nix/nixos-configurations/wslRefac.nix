{ inputs, pkgs, ... }:
let
  # Import shared user configurations
  userConfigs = import ./home-modules/userConfigurations.nix { inherit inputs; };
  defaultHMConfig = userConfigs.wsl;
in
{
  imports = [ inputs.agenix.nixosModules.age ];
  age.secrets.openrouterToken.file = ../home-modules/secrets/claudeToken.age;
  age.secrets.openrouterToken.owner = "mar";
  age.secrets.claudeToken.file = ../home-modules/secrets/claudeToken.age;
  age.secrets.claudeToken.owner = "mar";
  age.identityPaths = [ "/home/mar/.ssh/id_ed25519" ];
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  users.users.mar.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBR+GCws2rQ30VOYAvIiWtbRrHfveej4H2L+/s28JTCG trash@win"
  ];

  ##
  ## system modules config
  ##
  # Nixvim is now managed per-user via Home Manager

  myModules.wsl.enable = true;
  myModules.defaults.enable = true;

  # for vscode server
  programs.nix-ld.enable = true;

  # yubikey
  services.udev.packages = [ pkgs.yubikey-personalization ];
  security.pam.yubico = {
    enable = true;
    #debug = true;
    mode = "challenge-response";
  };
  # virtualisation.docker.enable = true;
  # users.groups.docker.members = [ "mar" ];
  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  nix.settings.trusted-users = [ "root" "mar" ];

  ## 
  ## users and homemanager modules config
  ## 
  myModules.createUsers = {
    enable = true;
    users = [
      # TODO: move this out into own users file
      { name = "mar"; homeManager = true; homeManagerConf = defaultHMConfig; }
      # { name = "test"; homeManager = true; }
      { name = "notHM"; homeManager = false; }
    ];
  };
}
