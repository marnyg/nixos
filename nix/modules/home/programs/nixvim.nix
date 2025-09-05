{ pkgs, lib, config, ... }:
with lib;
{
  options.modules.nixvim = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable nixvim (highly customized Neovim configuration)";
    };
  };

  config = mkIf config.modules.nixvim.enable {
    # Install neovim (the nixvim package would need to be passed through flake inputs)
    home.packages = [ pkgs.neovim ];

    # Set nvim as the default editor
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    # This could be extended to include the custom nixvim configuration
    # when the flake structure allows proper access to the custom package
  };
}
