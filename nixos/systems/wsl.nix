{ pkgs, inputs, config, ... }:
{
  nixpkgs.overlays = [ inputs.nur.overlay ];
  nixpkgs.config.allowUnfree = true;

  imports = [
    inputs.nixos-wsl.nixosModules.wsl
    inputs.home-manager.nixosModules.home-manager

  ] ++ (builtins.attrValues inputs.my-modules.nixosModules.x86_64-linux)
  ;

  modules.myNvim.enable = true;

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    defaultUser = "mar";
    startMenuLaunchers = true;

    # Enable native Docker support
    # docker-native.enable = true;
    # Enable integration with Docker Desktop (needs to be installed)
    docker-desktop.enable = true;
  };
  users.users.mar = { shell = pkgs.zsh; };
  programs.zsh.enable = true;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  #home-manager.sharedModules = my-homemanager-modules;
  home-manager.users =
    let
      createUserConf = user:
        {
          #imports = my-homemanager-modules ++ [
          imports = (builtins.attrValues inputs.my-modules.hmModules.x86_64-linux) ++ [
            {
              modules.zsh.enable = true;
              modules.direnv.enable = true;
              modules.zellij.enable = true;
              modules.tmux.enable = true;
              modules.firefox.enable = true;
              modules.autorandr.enable = false;
              modules.bspwm.enable = false;
              modules.dunst.enable = true;
              modules.kitty.enable = true;
              modules.git.enable = true;
              modules.newsboat.enable = true;
              modules.polybar.enable = false;
              modules.xmonad.enable = false;
              modules.spotifyd.enable = false;
              modules.other.enable = true;
              modules.myPackages.enable = true;
              modules.cloneDefaultRepos.enable = true;

              programs.home-manager.enable = true;
              programs.bash.enable = true;

              services.gpg-agent = {
                enable = true;
                enableSshSupport = true;
                enableZshIntegration = true;
              };

              home = {
                stateVersion = "22.11";
                username = user;

                sessionVariables = {
                  EDITOR = "vim";
                  TEST_VARIABLE = "THISISATESTSTRING";
                };

                file.".config/nixpkgs/config.nix" = {
                  text = ''
                    { allowUnfree = true; }
                  '';
                };

                sessionPath = [
                  "$HOME/go/bin"
                  "$HOME/.local/bin"
                  "$HOME/bin"
                ];
              };

            }
          ];
        };
    in
    {
      mar = createUserConf "mar";
      #    nixos = createUserConf "nixos";
    };

  environment.systemPackages = with pkgs; [
    wget
    curl
    lf
    htop
    zellij
  ];

  # Enable nix flakes
  nix = {
    settings.auto-optimise-store = true;
    package = pkgs.nixUnstable;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  system.stateVersion = "22.11";
}
