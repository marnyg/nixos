{ pkgs, inputs }:
{
  nixpkgs-fmt = pkgs.runCommand "Chech formating" { nativeBuildInputs = [ pkgs.nixpkgs-fmt ]; } ''
    nixpkgs-fmt --check ${./.}
    touch $out
  '';

  fooTest = pkgs.runCommand "foo test" { } ''
    echo ok
    touch $out
  '';

  miniOsTest = pkgs.nixosTest (import ../tests/mini.nix pkgs);
  miniOsTest2 = pkgs.nixosTest (import ../tests/mini2.nix pkgs);
  osWithHomemanager = pkgs.nixosTest (import ../tests/miniHomemanager.nix { inherit inputs pkgs; });
  #compositionTest = {...}: {
  #   inherit  miniOsTest miniOsTest2;
  #  #miniOsTest = pkgs.nixosTest (import ../tests/mini.nix pkgs);
  #  #miniOsTest2 = pkgs.nixosTest (import ../tests/mini2.nix pkgs);
  #};
  #run interactivly with
}
