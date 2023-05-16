pkgs:
let
  #making adhock shell scripts
  myArbetraryCommand = pkgs.writeShellScriptBin "tst" ''
    echo lala
    echo omekga
    ${pkgs.cowsay}/bin/cowsay lalal
    echo omekga
  '';

  #when we want to execute build steps, like creating a tarball or running a vm cluster for manual inspection
  myThatModifyesRepo = pkgs.writeShellScriptBin "tst2" '' 
    mkdir lala
    ${pkgs.cowsay}/bin/cowsay lalal > ./lala/cow
    echo did it
  '';

  #making adhock shell with dependensies in path
  myOtherCommand = pkgs.writeShellApplication
    {
      name = "show-nixos-org";
      runtimeInputs = with pkgs; [ curl w3m ];

      text = ''
        curl -s 'https://nixos.org' | w3m -dump -T text/html
      '';
    };

  #composit build steps
  comoposeScripts = pkgs.writeShellApplication
    {
      name = "comoposeScripts";
      runtimeInputs = [ myArbetraryCommand myOtherCommand ];

      text = ''
        show-nixos-org
        tst
      '';
    };
in
pkgs.mkShell {
  RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";

  nativeBuildInputs = with pkgs; [
    myArbetraryCommand
    comoposeScripts
    myOtherCommand
    myThatModifyesRepo

    nixpkgs-fmt
    shfmt
    rustc
    cargo
    rustfmt
    clippy
  ];
}
