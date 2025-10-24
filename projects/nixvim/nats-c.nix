{ pkgs, ... }:
with pkgs;
stdenv.mkDerivation rec {
  pname = "nats-c";
  version = "3.8.0";

  src = fetchFromGitHub {
    owner = "nats-io";
    repo = "nats.c";
    rev = "v${version}";
    sha256 = "sha256-fIm5RBX6m0zSeq2WvpIEi2+ibpnyqsFkeP0T9NS+sOw=";
  };

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [ openssl ];

  cmakeFlags = [
    "-DNATS_BUILD_WITH_TLS=ON"
    "-DNATS_BUILD_EXAMPLES=OFF"
    "-DNATS_BUILD_TESTS=OFF"
    # Fix the pkg-config issue
    "-DNATS_BUILD_STREAMING=OFF"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
  ];

  # Fix the pkg-config file after installation
  postFixup = ''
    # Fix the double slash issue in pkg-config file
    if [ -f "$out/lib/pkgconfig/libnats.pc" ]; then
      substituteInPlace "$out/lib/pkgconfig/libnats.pc" \
        --replace "\''${prefix}//" "/" \
        --replace "/\''${prefix}" "\''${prefix}"
    fi
  '';
}
