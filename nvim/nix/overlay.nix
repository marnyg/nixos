{ neovim-flake, vim-extra-plugins }:
final: prev:

let
  config-nvim = final.vimUtils.buildVimPluginFrom2Nix {
    name = "config-nvim";
    src = ../.;
  };
in

{
  my-neovim = final.callPackage ./pkgs/my-neovim.nix {
    neovim = neovim-flake.packages.${prev.system}.neovim;
    #neovim = neovim-flake.packages.${prev.system}.neovim-unwraped;
    #neovim = pkgs.legacyPackages.x86_64-linux.neovim-unwrapped;

    inherit config-nvim;
  };

  vimExtraPlugins = vim-extra-plugins.packages.${prev.system};
  # vimExtraPlugins = vim-extra-plugins.overlays.default.extend (self: super: {
  #   iron-nvim = super.iron-nvim.overrideAttrs (old: {
  #     patches = (old.patches or [ ]) ++ [
  #       # A workaround until https://github.com/hkupty/iron.nvim/pull/283 gets merged.
  #       (final.fetchpatch {
  #         url = "https://github.com/hkupty/iron.nvim/pull/283/commits/955e4553fe7dcdc2e2a3039bba0dd7bb6630440e.patch";
  #         sha256 = "sha256-Yw6W2m6efqwBEoJnnPqlBJ/hGvx3lbk5VtRbUBxDoVk=";
  #       })
  #       (final.fetchpatch {
  #         url = "https://github.com/hkupty/iron.nvim/pull/283/commits/66ab19b1b72fa9f82578b3686c4ada0b5a050c4e.patch";
  #         sha256 = "sha256-fqZO6hWSlYL/4cJTVOCXjRmL3YdmNDWKNf2veYLhlqI=";
  #       })
  #     ];
  #   });
  # });
}
