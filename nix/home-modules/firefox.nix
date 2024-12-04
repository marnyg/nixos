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
              tridactyl
              bitwarden

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
        search = {
          force = true;
          default = "Kagi";
          order = [ "Kagi" "Youtube" "NixOS Options" "Nix Packages" "Home Manager" "GitHub" ];


          engines = {
            "Bing".metaData.hidden = true;
            "Google".metaData.hidden = true;
            "eBay".metaData.hidden = true;
            "DuckDuckGo".metaData.hidden = true;
            "Amazon.com".metaData.hidden = true;
            "Wikipedia (en)".metaData.hidden = true;
            "YouTube".metaata.hidden = true;
            # "Kagi".metaData.hidden = true;
            # "Nix Packages".metaData.hidden = true;
            # "NixOS Options".metaData.hidden = true;
            # "Home Manager".metaData.hidden = true;
            # "SourceGraph".metaData.hidden = true;
            # "GitHub".metaData.hidden = true;

            "Kagi" = {
              urls = [
                {
                  template = "https://kagi.com/search";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
            };

            "Nix Packages" = {
              # icon = "https://nixos.org/_astro/flake-blue.Bf2X2kC4_Z1yqDoT.svg";
              iconUpdateURL = "https://nixos.org/_astro/flake-blue.Bf2X2kC4_Z1yqDoT.svg";
              definedAliases = [ "@np" ];
              urls = [
                {
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "type";
                      value = "packages";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                    {
                      name = "channel";
                      value = "unstable";
                    }
                  ];
                }
              ];
            };


            "NixOS Options" = {
              # icon = "https://nixos.org/_astro/flake-blue.Bf2X2kC4_Z1yqDoT.svg";
              iconUpdateURL = "https://nixos.org/_astro/flake-blue.Bf2X2kC4_Z1yqDoT.svg";
              definedAliases = [ "@no" ];
              urls = [
                {
                  template = "https://search.nixos.org/options";
                  params = [
                    {
                      name = "channel";
                      value = "unstable";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
            };

            "SourceGraph" = {
              iconUpdateURL = "https://sourcegraph.com/.assets/img/sourcegraph-mark.svg";
              definedAliases = [ "@sg" ];

              urls = [
                {
                  template = "https://sourcegraph.com/search";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
            };

            "GitHub" = {
              iconUpdateURL = "https://github.com/favicon.ico";
              updateInterval = 24 * 60 * 60 * 1000;
              definedAliases = [ "@gh" ];

              urls = [
                {
                  template = "https://github.com/search";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
            };

            "Home Manager" = {
              iconUpdateURL = "https://nixos.org/_astro/flake-blue.Bf2X2kC4_Z1yqDoT.svg";
              definedAliases = [ "@hm" ];

              urls = [
                {
                  template = "https://mipmip.github.io/home-manager-option-search/";
                  params = [
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];

            };
          };
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

