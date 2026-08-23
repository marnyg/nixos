# terminal-browser — a real browser inside your terminal (kitty graphics
# protocol + bundled Electron/Chromium). Packaged from the upstream prebuilt
# release tarballs; the bundled Electron is a custom zenbu build, so we
# autoPatchelf it rather than substituting nixpkgs' electron.
# Upstream: https://github.com/zenbu-labs/terminal-browser
{ lib
, stdenv
, fetchurl
, makeWrapper
, autoPatchelfHook
, alsa-lib
, at-spi2-atk
, at-spi2-core
, atk
, cairo
, cups
, dbus
, expat
, glib
, gtk3
, libgbm
, libglvnd
, libx11
, libxcb
, libxcomposite
, libxdamage
, libxext
, libxfixes
, libxkbcommon
, libxrandr
, nspr
, nss
, pango
, systemd
}:

let
  version = "0.6.0";

  sources = {
    x86_64-linux = fetchurl {
      url = "https://github.com/zenbu-labs/terminal-browser/releases/download/v${version}/terminal-browser-linux-x64.tar.gz";
      hash = "sha256-fCN1WTYjoSEJYV7KlM6u7OamGTxMyVW6FZIV8PbAn/c=";
    };
    aarch64-linux = fetchurl {
      url = "https://github.com/zenbu-labs/terminal-browser/releases/download/v${version}/terminal-browser-linux-arm64.tar.gz";
      hash = "sha256-JNBs4m/bhBcRTWFMW/Fu5IGqtXM/SeJPVXynoEGoL0o=";
    };
    aarch64-darwin = fetchurl {
      url = "https://github.com/zenbu-labs/terminal-browser/releases/download/v${version}/terminal-browser-darwin-arm64.tar.gz";
      hash = "sha256-0tGgYLYgjxyMUEoa+CXu0PsFv629iyPx4AZWGcV350k=";
    };
  };
in
stdenv.mkDerivation {
  pname = "terminal-browser";
  inherit version;

  src = sources.${stdenv.hostPlatform.system}
    or (throw "terminal-browser: unsupported system ${stdenv.hostPlatform.system}");

  nativeBuildInputs = [ makeWrapper ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  # DT_NEEDED of the bundled electron binary (+ libstdc++ for pixel.node).
  # libffmpeg/libEGL/libGLESv2 etc. are bundled alongside and resolved by
  # autoPatchelf from within $out.
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libgbm
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxkbcommon
    libxrandr
    nspr
    nss
    pango
    stdenv.cc.cc.lib
    (lib.getLib systemd) # libudev
  ];

  # dlopen'd at runtime
  runtimeDependencies = lib.optionals stdenv.hostPlatform.isLinux [
    libglvnd
    (lib.getLib systemd)
  ];

  dontConfigure = true;
  dontBuild = true;
  # Chromium binaries are already stripped; re-stripping is slow and risky.
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/terminal-browser $out/bin
    cp -r . $out/share/terminal-browser

    # Upstream launcher resolves its root from its own real path, so wrap
    # (not symlink) it into $out/bin.
    makeWrapper $out/share/terminal-browser/bin/terminal-browser \
      $out/bin/terminal-browser

    runHook postInstall
  '';

  # chrome-sandbox wants setuid root, which nix store paths can't provide.
  # Chromium falls back to the user-namespace sandbox, enabled by default
  # on NixOS, so this is fine.

  meta = with lib; {
    description = "A real browser that runs inside your terminal";
    homepage = "https://github.com/zenbu-labs/terminal-browser";
    license = licenses.mit;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    platforms = builtins.attrNames sources;
    mainProgram = "terminal-browser";
  };
}
