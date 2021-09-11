{
    description = "NixOS configuration";

    # All inputs for the system
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        nur = {
            url = "github:nix-community/NUR";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        #dwm = {
        #    url = "github:notusknot/dwm";
        #    inputs.nixpkgs.follows = "nixpkgs";
        #    flake = false;
        #};

        #st = {
        #    url = "github:notusknot/st";
        #    inputs.nixpkgs.follows = "nixpkgs";
        #    flake = false;
        #};

        #neovim-nightly-overlay = {
        #    url = "github:nix-community/neovim-nightly-overlay";
        #    inputs.nixpkgs.follows = "nixpkgs";
        #};
    };

    # All outputs for the system (configs)
    #outputs = { home-manager, nixpkgs, nur, neovim-nightly-overlay, st, dwm, ... }: {
    outputs = { home-manager, nixpkgs, nur,  ... }: {
        nixosConfigurations = {

            # Laptop config
            marlaptop = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                modules = [
                    ./configuration.nix ./config/laptop.nix ./config/packages.nix 
                    home-manager.nixosModules.home-manager {
                        home-manager.useGlobalPkgs = true;
                        home-manager.useUserPackages = true;
                        home-manager.users.mar = import ./config/home.nix;
                        nixpkgs.overlays = [ 
                        #    (final: prev: {
                        #        st = prev.st.overrideAttrs (o: {
                        #            src = st;
                        #        });
                        #    })
                        #    (final: prev: {
                        #        dwm = prev.dwm.overrideAttrs (o: {
                        #            src = dwm;
                        #        });
                        #    })
                            nur.overlay # neovim-nightly-overlay.overlay 
                        ];
                    }
                ];
            };

            # Desktop config
            mardesk = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                modules = [
                    ./configuration.nix ./config/desktop.nix ./config/packages.nix 
                    home-manager.nixosModules.home-manager {
                        home-manager.useGlobalPkgs = true;
                        home-manager.useUserPackages = true;
                        home-manager.users.mar = import ./config/home.nix;
                        nixpkgs.overlays = [ 
                        #    (final: prev: {
                        #        st = prev.st.overrideAttrs (o: {
                        #            src = st;
                        #        });
                        #    })
                        #    (final: prev: {
                        #        dwm = prev.dwm.overrideAttrs (o: {
                        #            src = dwm;
                        #        });
                        #    })
                            nur.overlay # neovim-nightly-overlay.overlay 
                        ];
                    }
                ];
            };
            # Desktop config
            new = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                modules = [
                    ./configuration.nix ./hardware-configuration.nix ./config/packages.nix 
                    #home-manager.nixosModules.home-manager {
                    #    home-manager.useGlobalPkgs = true;
                    #    home-manager.useUserPackages = true;
                    #    home-manager.users.mar = import ./config/home.nix;
                    #    nixpkgs.overlays = [ 
                    #    #    (final: prev: {
                    #    #        st = prev.st.overrideAttrs (o: {
                    #    #            src = st;
                    #    #        });
                    #    #    })
                    #    #    (final: prev: {
                    #    #        dwm = prev.dwm.overrideAttrs (o: {
                    #    #            src = dwm;
                    #    #        });
                    #    #    })
                    #        nur.overlay # neovim-nightly-overlay.overlay 
                    #    ];
                    #}
                ];
            };

            # Raspberry Pi config
            notuspi = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                modules = [
                    ./configuration.nix ./config/pi.nix
                ];
            };
        };
    };
}
