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
