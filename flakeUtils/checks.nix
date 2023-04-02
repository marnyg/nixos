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

  miniOsTest = pkgs.nixosTest (import ../tests/mini.nix);
  osWithMiniHomemanager = pkgs.nixosTest (import ../tests/miniHomemanager.nix inputs);
  osWithMyHomemanager = pkgs.nixosTest (import ../tests/withHomemanager.nix inputs);
  #osWithWsl = pkgs.nixosTest (import ../tests/withWsl.nix { inherit inputs pkgs; });
  osWithHomemanagerAndWsl = pkgs.nixosTest (import ../tests/withHmAndWsl.nix inputs);
}
