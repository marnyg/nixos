{ config, lib, ... }:
with lib;
{
  options.modules.firefox = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.firefox.enable {
    programs.firefox = {
      enable = true;
      profiles.mar = {
        extensions =
          mkIf
            (builtins.hasAttr "nur" config)
            (with config.nur.repos.rycee.firefox-addons; [
              decentraleyes
              ublock-origin
              clearurls
              sponsorblock
              darkreader
              #h264ify
              #df-youtube
              #tree-style-tab
              bitwarden
              vim-vixen
              sidebery
              #pkgs.saka
              #pkgs.saka-key
            ]);
        settings = {
          "browser.ctrlTab.sortByRecentlyUsed" = true;
          "browser.startup.page" = 3;
          "media.peerconnection.enabled" = false;
          "media.peerconnection.turn.disable" = true;
          "media.peerconnection.use_document_iceservers" = false;
          "media.peerconnection.video.enabled" = false;
          "media.peerconnection.identity.timeout" = 1;
          "privacy.resistFingerprinting" = true;
          "privacy.trackingprotection.fingerprinting.enabled" = true;
          "privacy.trackingprotection.cryptomining.enabled" = true;
          "privacy.trackingprotection.enabled" = true;
          "browser.send_pings" = false;
          "browser.urlbar.speculativeConnect.enabled" = false;
          "dom.event.clipboardevents.enabled" = false;
          "media.navigator.enabled" = false;
          "network.http.referer.XOriginTrimmingPolicy" = 2;
          "beacon.enabled" = false;
          "browser.safebrowsing.downloads.remote.enabled" = false;
          "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
          "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
          "browser.newtabpage.activity-stream.feeds.topsites" = false;
          "app.shield.optoutstudies.enabled" = false;
          "dom.security.https_only_mode_ever_enabled" = true;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "browser.toolbars.bookmarks.visibility" = "never";
          "browser.search.suggest.enabled" = false;
          "browser.urlbar.shortcuts.bookmarks" = false;
          "browser.urlbar.shortcuts.history" = false;
          "browser.urlbar.shortcuts.tabs" = false;
          "browser.urlbar.suggest.bookmark" = false;
          "browser.urlbar.suggest.engines" = false;
          "browser.urlbar.suggest.history" = true;
          "browser.urlbar.suggest.openpage" = false;
          "browser.urlbar.suggest.topsites" = false;
          "browser.uidensity" = 1;
          "media.autoplay.enabled" = false;
          "extensions.pocket.enabled" = false;
          "identity.fxaccounts.enabled" = false;
          "toolkit.zoomManager.zoomValues" = ".8,.95,1,1.1,1.2";
          "layout.css.devPixelsPerPx" = 0.8;
        };
        userChrome = ''
          /* hides the native tabs */
          #TabsToolbar {
            visibility: collapse;
          }
          #titlebar {
            visibility: collapse;
          }
        '';
      };
    };
  };
}

