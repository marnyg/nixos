{ pkgs, lib, config, ... }:
with lib;
{
  options.modules.myNvim = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.myNvim.enable {

    programs.neovim.enable = true;
    #programs.neovim.package = (import ./nix/newnvim.nix { inherit pkgs; neovim = pkgs.neovim; });
    environment.systemPackages = with pkgs; [
      hunspell # TODO: set up spelling in nvim
      hunspellDicts.en-us
      rnix-lsp
      haskell-language-server
      sumneko-lua-language-server
      rust-analyzer
      elmPackages.elm-language-server
      (import ./nix/newnvim.nix { inherit pkgs; neovim = pkgs.neovim; })
    ];
  };
}
