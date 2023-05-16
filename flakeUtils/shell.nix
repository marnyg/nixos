pkgs:
let
  myArbetraryCommand = pkgs.writeShellScriptBin "tst" ''
    echo lala
    echo omekga
    ${pkgs.cowsay}/bin/cowsay lalal
    echo omekga
  '';
  myOtherCommand = pkgs.writeShellApplication
    {
      name = "show-nixos-org";

      runtimeInputs = with pkgs; [ curl w3m ];

      text = ''
        curl -s 'https://nixos.org' | w3m -dump -T text/html
      '';
    };
in
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
