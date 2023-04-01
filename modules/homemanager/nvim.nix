{ pkgs, lib, config, ... }:
with lib;
{
  options.modules.nvim = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.nvim.enable {
    #programs.neovim = {
    #  enable = true;
    #   package = pkgs.my-neovim;
    ##  #finalPackage = pkgs.my-neovim;
    #  extraPackages = with pkgs; [
    # # Language servers;
    #    hunspell # TODO: set up spelling in nvim
    #    hunspellDicts.en-us
    #    rnix-lsp
    #    haskell-language-server
    #    sumneko-lua-language-server
    #    elmPackages.elm-language-server
    #  ];

    #};sdasd

    #home.packages = with pkgs; [
    #  #my-neovim
    #  hunspell # TODO: set up spelling in nvim
    #  hunspellDicts.en-us
    #  rnix-lsp
    #  haskell-language-server
    #  sumneko-lua-language-server
    #  elmPackages.elm-language-server
    #];
  };
}
