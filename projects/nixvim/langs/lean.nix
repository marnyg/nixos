{ config, lib, ... }:
with lib;
{
  options.langs.lean = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Lean support.";
    };
    lsp.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable LSP server.";
    };
  };

  config = mkIf config.langs.lean.enable {
    # lean.nvim: filetype, abbreviations, infoview and LSP integration
    plugins.lean = {
      enable = true;
      settings = {
        lsp.enable = config.langs.lean.lsp.enable;
        mappings = true;
        abbreviations.enable = true;
        infoview = {
          autoopen = true;
          horizontal_position = "bottom";
          indicators = "auto";
        };
      };
    };
  };
}
