{ lib, config, pkgs, ... }:
with lib;
{
  options.modules.qutebrowser = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.qutebrowser.enable {
    home.packages = [ pkgs.keyutils ];
    home.sessionVariables.QT_SCALE_FACTOR = "1.5";
    home.sessionVariables.b = "1.5";

    xdg.mimeApps.enable = true;
    xdg.mimeApps.defaultApplications = {
      "x-scheme-handler/http" = "qutebrowser.desktop";
      "x-scheme-handler/https" = "qutebrowser.desktop";
      "text/html" = "qutebrowser.desktop";
      "application/xhtml+xml" = "qutebrowser.desktop";
      "application/x-extension-htm" = "qutebrowser.desktop";
      "application/x-extension-html" = "qutebrowser.desktop";
      "application/x-extension-shtml" = "qutebrowser.desktop";
      "inode/directory" = "qutebrowser.desktop";
      "x-scheme-handler/about" = "qutebrowser.desktop";
      "text/plain" = "qutebrowser.desktop";
      "application/x-extension-txt" = "qutebrowser.desktop";
      "text/x-readme" = "qutebrowser.desktop";
      "x-scheme-handler/unknown" = "qutebrowser.desktop";
    };

    programs.qutebrowser = {
      enable = true;
      settings = {
        qt.highdpi = true;
        auto_save.session = true;
        tabs.position = "left";

      };
      keyBindings = {
        normal = {
          "<Ctrl-v>" = "spawn mpv {url}";
          "<Ctrl-Shift-b>" = "spawn --userscript qute-bitwarden";

        };
      };
    };
  };
}
