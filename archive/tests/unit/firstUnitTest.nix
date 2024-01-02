{ pkgs ? import <nixpkgs> { }, self }:

let
  lib = pkgs.lib;
in
lib.runTests {
  name = "your-flake-tests";
  tests = [
    {
      testFunction = self.nixosConfigurations.wsl2;
      expectedResult = "expected result";
    }
  ];
}
