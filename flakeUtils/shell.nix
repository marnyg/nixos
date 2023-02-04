pkgs:
{
  default = pkgs.mkShell {
    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";

    nativeBuildInputs = with pkgs; [
      nixpkgs-fmt
      shfmt
      rustc
      cargo
      rustfmt
      clippy
    ];
  };
}
