{ pkgs, config, ... }: {
  #programs.neovim = {
  #  enable = true;
  #  #package = pkgs.my-neovim;
  #  #finalPackage = pkgs.my-neovim;
  #  extraPackages = with pkgs; [
  #    # Language servers;
  #    hunspell # TODO: set up spelling in nvim
  #    hunspellDicts.en-us
  #    rnix-lsp
  #    haskell-language-server
  #    sumneko-lua-language-server
  #    elmPackages.elm-language-server
  #  ];

  #};

    home.packages = with pkgs; [
      my-neovim
      hunspell # TODO: set up spelling in nvim
      hunspellDicts.en-us
      rnix-lsp
      haskell-language-server
      sumneko-lua-language-server
      elmPackages.elm-language-server
    ];
}
