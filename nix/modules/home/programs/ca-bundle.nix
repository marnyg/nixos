# Combined CA bundle for OpenSSL-based tools (nix-profile curl, python, node, ...)
# that ignore the macOS keychain. Appends locally-trusted CAs (e.g. mkcert roots)
# to the standard cacert bundle and points the usual env vars at the result.
#
# The bundle is rebuilt:
#   - on every `home-manager switch` / activation, and
#   - (Darwin) automatically via a launchd agent that watches the extra cert
#     files and rebuilds within seconds when a CA is (re)generated.
{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.modules.my.caBundle;
  bundleDir = "${config.xdg.dataHome}/ssl";
  bundlePath = "${bundleDir}/ca-bundle.pem";

  buildScript = pkgs.writeShellScript "build-ca-bundle" ''
    set -eu
    mkdir -p "${bundleDir}"
    # mktemp inside the target dir so the final mv is atomic
    tmp="$(mktemp "${bundleDir}/.ca-bundle.XXXXXX")"
    trap 'rm -f "$tmp"' EXIT
    cat "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" > "$tmp"
    for cert in ${escapeShellArgs cfg.extraCertFiles}; do
      if [ -f "$cert" ]; then
        cat "$cert" >> "$tmp"
      else
        echo "caBundle: skipping missing cert: $cert" >&2
      fi
    done
    chmod 644 "$tmp"
    mv "$tmp" "${bundlePath}"
    trap - EXIT
  '';
in
{
  options.modules.my.caBundle = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Build a combined CA bundle (cacert + extra local CAs) and export SSL cert env vars.";
    };
    extraCertFiles = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = literalExpression ''[ "''${config.home.homeDirectory}/Library/Application Support/grove/ca/rootCA.pem" ]'';
      description = "Absolute paths to extra PEM certificates to append. Missing files are skipped with a warning.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.activation.buildCaBundle = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run ${buildScript}
      '';

      home.sessionVariables = {
        SSL_CERT_FILE = bundlePath; # OpenSSL and friends
        NIX_SSL_CERT_FILE = bundlePath; # nix itself
        CURL_CA_BUNDLE = bundlePath; # curl CLI
        REQUESTS_CA_BUNDLE = bundlePath; # python requests
        NODE_EXTRA_CA_CERTS = bundlePath; # node (appends to its built-in roots)
      };
    }

    (mkIf pkgs.stdenv.isDarwin {
      # Rebuild the bundle whenever a watched CA file (or its directory)
      # changes, e.g. after `mkcert -install` regenerates the root CA.
      launchd.agents.ca-bundle = {
        enable = true;
        config = {
          Label = "org.nix-community.home.ca-bundle";
          ProgramArguments = [ "${buildScript}" ];
          RunAtLoad = true;
          # Watch parent dirs too: editors/tools often replace files by
          # rename, which a watch on the file itself can miss.
          WatchPaths = unique (cfg.extraCertFiles ++ map dirOf cfg.extraCertFiles);
          StandardErrorPath = "/tmp/ca-bundle-agent.log";
        };
      };
    })
  ]);
}
