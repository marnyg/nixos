{ pkgs, lib, config, inputs, ... }:
with lib;
let
  # Get the nixvim package from the flake
  nixvim = inputs.self.packages.${pkgs.system}.nixvim or pkgs.neovim;
in
{
  options.modules.my.nixvim = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable nixvim (highly customized Neovim configuration)";
    };
  };

  config = mkIf config.modules.my.nixvim.enable {
    # Install the custom nixvim package and related tools
    home.packages = [ nixvim ] ++ (with pkgs; [
      # Language servers and tools that nixvim might use
      ripgrep
      fd
      fzf
      tree-sitter
    ]);

    # Set nvim as the default editor
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    # Create vim/nvim aliases to use nixvim
    home.shellAliases = {
      vim = "nvim";
      vi = "nvim";
    };
  };
}
