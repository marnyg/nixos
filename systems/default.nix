inputs:
let
  system = "x86_64-linux";
  my-homemanager-modules = builtins.attrValues inputs.my-modules.hmModules.${system};
  systemModules = [ inputs.nixos-wsl.nixosModules.wsl ]
    ++ builtins.attrValues inputs.my-modules.nixosModules.${system}
    ++ [ (inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix") ]
    ++ [ inputs.home-manager.nixosModules.home-manager ];


  mkSystem = systemConf:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs my-homemanager-modules; };
      modules = [ systemConf ] ++ systemModules;
    };
in
{
  desktop = mkSystem (import ./desktop/mar.nix);
  #laptop= mkSystem (import ./desktop/mar.nix);
  wsl = mkSystem (import ./wsl.nix);
  miniWsl = inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    #specialArgs = { inherit inputs my-homemanager-modules; };
    modules = [
      ({pkgs,...}: {
        imports = [ inputs.nixos-wsl.nixosModules.wsl ];

        wsl = {
          enable = true;
          wslConf.automount.root = "/mnt";
          defaultUser = "nixos";
          startMenuLaunchers = true;

          # Enable native Docker support
          # docker-native.enable = true;

          # Enable integration with Docker Desktop (needs to be installed)
          # docker-desktop.enable = true;

        };

        # Enable nix flakes
        nix.package = pkgs.nixFlakes;
        nix.extraOptions = ''
          experimental-features = nix-command flakes
        '';

        system.stateVersion = "22.11";

      }
      )
    ];
  };
  #pi= mkSystem (import ./wsl.nix);
}
