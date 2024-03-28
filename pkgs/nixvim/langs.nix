{ config, ... }:
{
  options = { };
  config = {
    plugins = {
      lsp = {
        enable = true;
        servers = {
          gopls.enable = true;
        };
      };
    };
  };
}
