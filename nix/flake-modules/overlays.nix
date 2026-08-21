# Overlays flake module
{ inputs, ... }:

{
  # Define overlays that can be used across the flake
  flake.overlays = {
    # Default overlay with custom packages
    default = final: prev: {
      # Custom packages from inputs
      mcphub-nvim = inputs.mcphub-nvim.packages.${final.system}.default or null;
      mcphub = inputs.mcphub.packages.${final.system}.default or null;

      # Replace neovim with nixvim globally
      neovim = inputs.self.packages.${final.system}.nixvim or prev.neovim;

      # Hyprland's Lua config mode (wayland.windowManager.hyprland.configType =
      # "lua" in modules/home/programs/hyprland.nix) makes the IPC `dispatch`
      # endpoint evaluate its argument as Lua, so waybar's hardcoded legacy
      # dispatch strings ("dispatch workspace name:3") come back as Lua syntax
      # errors and clicking a workspace button does nothing. Translate them to
      # Lua dispatcher objects (hl.dsp.focus / hl.dsp.workspace.toggle_special).
      # Drop this once waybar speaks Lua natively, Hyprland accepts legacy
      # dispatch strings again, or hyprland.nix leaves configType = "lua".
      waybar = prev.waybar.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [ ../overlays/waybar/hyprland-lua-dispatch.patch ];
      });

      # herdr 0.8.2: terminal-browser >= 0.5.7 passes `--right-click pane`
      # to `herdr pane split`, which nixpkgs' herdr 0.8.0 doesn't know
      # (browser split fails to open). cargoDeps is overridden explicitly
      # because this nixpkgs pin's buildRustPackage doesn't recompute the
      # vendor hash from an overridden cargoHash. zigDeps (libghostty-vt)
      # is unchanged between 0.8.0 and 0.8.2, so it follows finalAttrs.src
      # with the original hash. Drop this once nixpkgs ships >= 0.8.2.
      herdr = prev.herdr.overrideAttrs (_: rec {
        version = "0.8.2";
        src = prev.fetchFromGitHub {
          owner = "herdrdev";
          repo = "herdr";
          tag = "v${version}";
          hash = "sha256-sEGIN3dLZasaHob3EHscWBCIQHflMQVchYmzgsETDk4=";
        };
        cargoDeps = prev.rustPlatform.fetchCargoVendor {
          inherit src;
          name = "herdr-${version}-vendor";
          hash = "sha256-4VThqPwYYEsGvaOKjBeL6XAC5bnNWB6oUMWP/uXc/UQ=";
        };
      });

      # direnv's shell test suite hangs in the Darwin nix-build sandbox.
      direnv =
        if prev.stdenv.isDarwin
        then prev.direnv.overrideAttrs (_: { doCheck = false; })
        else prev.direnv;
    };

    # NUR overlay
    nur = inputs.nur.overlays.default;
  };

  # Apply overlays to nixpkgs per system
  perSystem = { system, ... }: {
    # Make overlays available in perSystem context
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        inputs.nur.overlays.default
        (final: prev: {
          mcphub-nvim = inputs.mcphub-nvim.packages.${final.system}.default or null;
          mcphub = inputs.mcphub.packages.${final.system}.default or null;
          # Replace neovim with nixvim globally
          neovim = inputs.self.packages.${final.system}.nixvim or prev.neovim;
        })
      ];
    };
  };
}
