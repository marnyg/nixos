{ pkgs, inputs, self }:
{
  nixpkgs-fmt = pkgs.runCommand "Chech formating" { nativeBuildInputs = [ pkgs.nixpkgs-fmt ]; } ''
    nixpkgs-fmt --check ${./.}
    touch $out
  '';
  nixtTestEval2 = import ../tests/test.nix { inherit pkgs; };

  #nixtTestEval = pkgs.runCommand "nixt unit test eval"
  #  { buildInputs = [ pkgs.nix ]; }
  #  ''
  #    nix eval --experimental-features nix-command --impure --expr 'import ${../tests/test.nix} {}'
  #  '';



  #  nixtTest = pkgs.runCommand "nixt unit test"
  #    { buildInputs = [ inputs.nixt.x86_64-linux.app.packages.default ]; }
  #    ''
  #      nixt
  #      touch $out
  #    '';

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
