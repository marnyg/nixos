{ self, pkgs ? import <nixpkgs> { } }:
let
  os = self.nixosConfigurations.wsl2;

  getNestedAttr = attrList: obj:
    pkgs.lib.attrByPath attrList (throw "${builtins.concatStringsSep "." attrList} does not exist") obj;

  hasAttr = str: obj:
    (builtins.tryEval (getNestedAttr (builtins.filter (x: x != [ ]) (builtins.split "\\." str)) obj)).success;


  testResults = pkgs.lib.runTests {
    testdunstEnabled = {
      expr = os.config.home-manager.users.mar.services.dunst.enable;
      expected = true;
    };
    testUndefinedAttr = {
      expr = hasAttr "a.b.c" os;
      expected = false;
    };
    testHasDefinedAttr = {
      expr = hasAttr "config.programs" os;
      expected = true;
    };
    testSubStr = {
      expr = [ ] == builtins.match (".*mar.*") os.config.home-manager.users.mar.services.dunst.configFile;
      expected = true;
    };
    testNotSubStr = {
      expr = [ ] == builtins.match (".*lal.*") os.config.home-manager.users.mar.services.dunst.configFile;
      expected = false;
    };
  };

  testScript = pkgs.writeScript "run-tests.sh" ''
    #!/bin/sh
    ${builtins.concatStringsSep "\n" (
      builtins.map (result:
        "echo 'Test ${result.name} expected: ${builtins.toString result.expected}, got ${builtins.toString result.result}'"
      ) testResults
    )}
    if [ '${builtins.toString (builtins.length  testResults != 0)}' == '1' ]; then exit 1; fi
    touch $out
  '';
in
pkgs.runCommandNoCC "run-tests" { } ''
  sh ${testScript}
''

