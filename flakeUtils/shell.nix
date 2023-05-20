{ pkgs, self }:
let
  #run all nix unit tests. this is quicker than running `nix flake check`
  allChecks = builtins.attrNames self.checks.x86_64-linux;
  nixtTestEval = pkgs.writeShellScriptBin "unit.sh" ''
    #!/bin/sh
    ${builtins.concatStringsSep "\n" (
      builtins.map (attr:
       "nix build .#checks.x86_64-linux.${attr}"
      ) allChecks
    )}
  '';


  #making adhock shell scripts
  myArbetraryCommand = pkgs.writeShellScriptBin "tst.sh" "${pkgs.cowsay}/bin/cowsay lalal";

  #making adhock shell with dependensies in path
  myOtherCommand = pkgs.writeShellApplication {
    name = "show-nixos-org.sh";
    runtimeInputs = with pkgs; [ curl w3m ];
    text = "curl -s 'https://nixos.org' | w3m -dump -T text/html";
  };

  buildWslImage = pkgs.writeShellScriptBin "buildWslImage.sh" '' 
      nix build .#nixosConfigurations.wsl.config.system.build.installer
    '';
  buildWslImageAndOpenInExplorer = pkgs.writeShellScriptBin "buildWslImageAndOpenInExplorer.sh" '' 
      ${buildWslImage}/bin/buildWslImage.sh 
      wt.exe -w 0 nt -d  $(/bin/wslpath -w $(realpath result/tarball))
      echo "wsl --unregister MyNixOsAuto; wsl --import MyNixOsAuto C:\Users\trash\wlsTarbals\NixosAuto .\nixos-wsl-installer.tar.gz --version 2; wsl -d mynixos2"
      echo "wsl --unregister MyNixOsAuto; wsl --import MyNixOsAuto C:\Users\trash\wlsTarbals\NixosAuto .\nixos-wsl-installer.tar.gz --version 2; wsl -d mynixos2" |clip.exe
    '';

  #composit build steps
  comoposeScripts = pkgs.writeShellApplication
    {
      name = "comoposeScripts.sh";
      runtimeInputs = [ myArbetraryCommand myOtherCommand ];
      text = "show-nixos-org.sh && tst.sh";
    };

in
pkgs.mkShell {
  RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";

  nativeBuildInputs = with pkgs; [
    myArbetraryCommand
    comoposeScripts
    myOtherCommand

    nixtTestEval
    buildWslImage
    buildWslImageAndOpenInExplorer

    nixpkgs-fmt
    shfmt
    rustc
    cargo
    rustfmt
    clippy
  ];
}
