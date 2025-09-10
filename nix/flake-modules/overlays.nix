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
