{ pkgs ? import <nixpkgs> { } }:
let
  isEven = x: pkgs.lib.mod x 2 == 0;

  testResults = pkgs.lib.runTests {
    testIsEven_1 = {
      expr = isEven 2;
      expected = true;
    };

    testIsEven_2 = {
      expr = isEven (-2);
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

