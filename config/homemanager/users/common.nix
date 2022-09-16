{ config, pkgs, ... }: {

  # Settings for XDG user directory, to declutter home directory
  xdg.userDirs = {
    enable = true;
    documents = "$HOME/stuff/other/";
    download = "$HOME/stuff/other/";
    videos = "$HOME/stuff/other/";
    music = "$HOME/stuff/music/";
    pictures = "$HOME/stuff/pictures/";
    desktop = "$HOME/stuff/other/";
    publicShare = "$HOME/stuff/other/";
    templates = "$HOME/stuff/other/";
  };

  # Settings for gpg
  programs.gpg = { enable = true; };

  # Fix pass
  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "qt";
  };
}
