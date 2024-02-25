{ lib, config, pkgs, ... }:
with lib;
{
  options.myModules.myNvim = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.myModules.myNvim.enable {

    programs.neovim.enable = true;
    environment.systemPackages = with pkgs; [
      hunspell # TODO: set up spelling in nvim
      hunspellDicts.en-us
      #rnix-lsp
      #haskell-language-server
      #sumneko-lua-language-server
      #rust-analyzer
      #elmPackages.elm-language-server
      (import ./nix/newnvim.nix { inherit pkgs; })
    ];
  };
}
