{ pkgs, inputs, self }:
{
  nixpkgs-fmt = pkgs.runCommand "Chech formating" { nativeBuildInputs = [ pkgs.nixpkgs-fmt ]; } ''
    nixpkgs-fmt --check ${./.}
    touch $out
  '';

  fooTest = pkgs.runCommand "foo test" { } ''
    echo ok
    touch $out
  '';
  #nixUnitTestFoo = (import ../test.nix);

  #attributeTest = (import ../nixos/tests/unit/attribute-test.nix { pkgs = nixpkgs.legacyPackages.${system}; myflake = self; });
  miniOsTest = pkgs.nixosTest (import ../nixos/tests/integration/mini.nix);
  osWithMiniHomemanager = pkgs.nixosTest (import ../nixos/tests/integration/miniHomemanager.nix inputs);
  osWithMyHomemanager = pkgs.nixosTest (import ../nixos/tests/integration/withHomemanager.nix inputs);
  #osWithHomemanagerAndWsl = pkgs.nixosTest (import ../nixos/tests/integration/withHmAndWsl.nix inputs);
}
