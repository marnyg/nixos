{ self, pkgs ? import <nixpkgs> { } }:
let
  os = self.nixosConfigurations.wsl2;

  getNestedAttr = attrList: obj:
    pkgs.lib.attrByPath attrList (throw "${builtins.concatStringsSep "." attrList} does not exist") obj;

  hasAttr = str: obj:
    (builtins.tryEval (getNestedAttr (builtins.filter (x: x != [ ]) (builtins.split "\\." str)) obj)).success;

  hasSubstr = str: substr: null != builtins.match (".*${substr}.*") str;


  attrsToExist = [
    #wsl module exist
    "config.wsl"
    #system modules
    "config.modules.myNvim"
    "config.users.users.mar"

    #system programs
    "config.programs.tmux"
    "config.programs.zsh"
    "config.programs.firefox"
    "config.programs.fzf"
    "config.programs.git"

    #system services
    "config.systemd.services.docker"
    "options.home-manager.users.value.mar"


    #home manager modules
    "config.home-manager.users.mar.services.dunst"

    #home manager services
    "config.home-manager.users.mar.systemd.user.services.cloneDefaultRepos"
    "config.home-manager.users.mar.systemd.user.services.cloneWorkRepos"
    "config.home-manager.users.mar.systemd.user.services.copySshFromHost"

    #home manager programs 
    "config.home-manager.users.mar.programs.direnv"
  ];

  # Generate a test for each attribute
  generatedTests = builtins.foldl'
    (tests: attr: tests // {
      "${"testHasDefined_" + builtins.replaceStrings ["."] ["_"] attr}" = {
        expr = hasAttr attr os;
        expected = true;
      };
    })
    { }
    attrsToExist;

  manualTests = {
    testWSLed = {
      expr = os.config.wsl.enable;
      expected = true;
    };
    testDunstEnabled = {
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
      expr = hasSubstr os.config.home-manager.users.mar.services.dunst.configFile "mar";
      expected = true;
    };
    testNotSubStr = {
      expr = hasSubstr os.config.home-manager.users.mar.services.dunst.configFile "nope";
      expected = false;
    };
  };

  testResults = pkgs.lib.runTests (generatedTests // manualTests);

  testScript = pkgs.writeScript "run-tests.sh" ''
    #!/bin/sh
    ${builtins.concatStringsSep "\n" (
      builtins.map (result:
       let 
          testName = result.name;
          expected = builtins.toJSON result.expected;
          got = builtins.toJSON result.result;
          passFail = if expected == got then "PASSED" else "FAILED" ;
        in 
        "echo '${passFail} - Test ${testName}: expected ${expected}, got ${got}'"
      ) testResults
    )}
    if [ '${builtins.toString (builtins.length  testResults != 0)}' == '1' ]; then exit 1; fi
    touch $out
  '';
in
pkgs.runCommandNoCC "run-tests" { } ''
  sh ${testScript}
''

