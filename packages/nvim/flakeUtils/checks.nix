{ pkgs, ... }:
{
  nixpkgs-fmt = pkgs.runCommand "Chech formating" { nativeBuildInputs = [ pkgs.nixpkgs-fmt ]; } ''
    nixpkgs-fmt --check ${./.}
    touch $out
  '';

  fooTest = pkgs.runCommand "foo test" { } ''
    echo ok
    touch $out
  '';
}
