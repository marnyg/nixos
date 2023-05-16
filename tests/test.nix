{ pkgs ? import <nixpkgs> { } }:
let
  lib = pkgs.lib;
  math = import ./isEven.nix { inherit lib; };

  testResults = lib.runTests {
    testIsEven_1 = {
      expr = math.isEven 2;
      expected = true;
    };

    testIsEven_2 = {
      expr = math.isEven (-2);
      expected = true;
    };
  };

  testScript = pkgs.writeScript "run-tests.sh" ''
    #!/bin/sh
    ${builtins.concatStringsSep "\n" (
      builtins.map (result:
        "echo 'Test ${result.name} expected: ${builtins.toString result.expected}, got ${builtins.toString result.result}'; exit 1"
      ) testResults
    )}
    touch $out
  '';
in
pkgs.runCommandNoCC "run-tests" { } ''
  sh ${testScript}
''

