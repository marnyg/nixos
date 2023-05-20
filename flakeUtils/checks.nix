{ pkgs, inputs, self }:
{
  nixpkgs-fmt = pkgs.runCommand "Chech formating" { nativeBuildInputs = [ pkgs.nixpkgs-fmt ]; } ''
    nixpkgs-fmt --check ${./.}
    touch $out
  '';
  unitTestExample = import ../tests/test.nix { inherit pkgs; };
  checkAttrsOnFakeOsfakeConfig = import ../tests/testIfAttrExist.nix { inherit pkgs; };
  checkAttrsEqualsOnWslConf = import ../tests/testAttrsEqualsOnWsl.nix { inherit pkgs self; };
  checkAttrsEqualsOnRefactoredWslConf = import ../tests/testAttrsEqualsOnRefactoredWsl.nix { inherit pkgs self; };

  fooTest = pkgs.runCommand "foo test" { } ''
    echo ok
    # uncomment below to make derivation fail its evaluation
    #exit 1
    touch $out
  '';
  #nixUnitTestFoo = (import ../test.nix);

  #unitTest = pkgs.callPackage ../nixos/tests/unit/firstUnitTest.nix {inherit pkgs self; }; 
  #attributeTest = (import ../nixos/tests/unit/attribute-test.nix { pkgs = nixpkgs.legacyPackages.${system}; myflake = self; });
  miniOsTest = pkgs.nixosTest (import ../nixos/tests/integration/mini.nix);
  osWithMiniHomemanager = pkgs.nixosTest (import ../nixos/tests/integration/miniHomemanager.nix inputs);
  osWithMyHomemanager = pkgs.nixosTest (import ../nixos/tests/integration/withHomemanager.nix inputs);
  #osWithHomemanagerAndWsl = pkgs.nixosTest (import ../nixos/tests/integration/withHmAndWsl.nix inputs);
}
