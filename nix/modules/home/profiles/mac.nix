# Home-manager profile for macOS systems
{ pkgs, lib, config, ... }:
{
  imports = [ ./developer.nix ];

  # macOS-specific module configurations
  modules.my = {
    # Disable Linux-specific modules
    sharedDefaults.enable = false;
    cloneDefaultRepos.enable = false;

    # Enable macOS-compatible programs
    firefox.enable = lib.mkDefault true;
    kitty.enable = lib.mkDefault false; # Disabled - build fails on Darwin, using Ghostty instead
    ghostty.enable = lib.mkDefault true;
    ghostty.fontsize = lib.mkDefault 14;
    swiftbar.enable = lib.mkDefault true; # Menu bar widgets (Claude usage)
    spotifyd.enable = lib.mkDefault false;

    # Development tools (with performance optimizations)
    direnv.enable = lib.mkDefault true; # nix-direnv caches flake evaluations
    git.enable = lib.mkDefault true;
    tmux.enable = lib.mkDefault true;
    fish.enable = lib.mkDefault true;

    # Combined CA bundle so OpenSSL-based tools (nix-profile curl etc.)
    # trust the grove mkcert root CA without --cacert.
    caBundle = {
      enable = lib.mkDefault true;
      extraCertFiles = [
        "${config.home.homeDirectory}/Library/Application Support/grove/ca/rootCA.pem"
      ];
    };
  };


  # Syncthing against the cluster peer over the mesh (talos-config
  # ADR-0046): the gateway's `syncthing` facet at
  # tcp://syncthing.gw.mesh.internal:22000 on this device's utun
  # (services.talos-mesh). Static peer — no discovery, relays or NAT.
  # Folders by temperature: `notes` + `docs` here; `media` stays on the
  # desktop + cluster. Declarative: this file is the truth for devices
  # and folders (override*), the GUI at 127.0.0.1:8384 is for status.
  # The cluster side names this device by its ID
  # (`syncthing --device-id`, state in ~/Library/Application Support/
  # Syncthing). The linux twin is modules.my.syncthing (nixos).
  services.syncthing = {
    enable = true;
    overrideDevices = true;
    overrideFolders = true;
    settings = {
      devices.cluster = {
        id = "MH66KIH-ITKUVDR-YUBLROU-P7PCVQP-JSNJFLC-TJ72XPP-HILWDZO-XSVMRQC";
        addresses = [ "tcp://syncthing.gw.mesh.internal:22000" ];
      };
      folders = {
        notes = { path = "${config.home.homeDirectory}/Sync/notes"; devices = [ "cluster" ]; };
        docs = { path = "${config.home.homeDirectory}/Sync/docs"; devices = [ "cluster" ]; };
      };
      options = {
        globalAnnounceEnabled = false;
        relaysEnabled = false;
        natEnabled = false;
        localAnnounceEnabled = true;
        urAccepted = -1;
        crashReportingEnabled = false;
        listenAddresses = [ "tcp://0.0.0.0:22000" ];
      };
      gui.address = "127.0.0.1:8384";
    };
  };

  # macOS-specific programs
  programs = {
    ncspot.enable = lib.mkDefault false;
    spotify-player.enable = lib.mkDefault true;
    spotify-player.settings = {
      login_redirect_uri = "http://127.0.0.1:8988/login";
      enable_media_control = true;
      device.name = "marius-mac-cli";
    };
    htop.enable = lib.mkDefault true;
    htop.settings.show_program_path = lib.mkDefault true;
    yazi.enable = lib.mkDefault true;
    yazi.shellWrapperName = "y";

    direnv = {
      enable = lib.mkDefault true;
      nix-direnv.enable = lib.mkDefault true;
    };
  };

  # macOS-specific packages
  home.packages = with pkgs; [
    # Core utilities
    coreutils
    curl
    wget
    jq
    ripgrep
    fd
    bat
    eza
    nss.tools # certutil — lets `grove dev trust` install the mkcert CA into Firefox's NSS store

    # Communication tools (if available on Darwin)
  ] ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
    # Darwin-only packages
    mas # Mac App Store CLI
  ] ++ lib.optionals (pkgs.stdenv.hostPlatform.isLinux) [
    # Linux-only packages (won't be included on Darwin)
    slack
    teams-for-linux
  ];

  # Environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
