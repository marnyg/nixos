{ pkgs ? import <nixpkgs> { } }:
let
  #  lib = pkgs.lib;
  #  math = import ./isEven.nix { inherit lib; };


  ## Define the configuration
  #myConfiguration = {
  #  imports = [ ./configuration.nix ]; # Your actual configuration
  #};
  ## Evaluate the configuration
  #config = (lib.evalModules { modules = [ myConfiguration ]; }).config;
  ## Now you can access the attributes of the configuration
  #userExists = builtins.hasAttr "mar" config.users.users;

  #fake os config
  config = {
    users.users = {
      mar = { };
      mar2 = { };
    };
    systemd.services.docker = { };
    programs.git = { };
  };

  testResults = [
    { exists = builtins.hasAttr "mar" config.users.users; description = "user mar exixts"; }
    { exists = builtins.hasAttr "mar2" config.users.users; description = "user mar2 exixts"; }
    { exists = builtins.hasAttr "docker" config.systemd.services; description = "docker service exists"; }
    { exists = builtins.hasAttr "git" config.programs; description = "git program exits"; }
  ];




  testScript = pkgs.writeScript "run-tests.sh" ''
    #!/bin/sh
    ${builtins.concatStringsSep "\n" (
      builtins.map (result:
        "if [ '${builtins.toString result.exists}' != '1' ]; then echo 'Test ${result.description} failed'; fi"
      ) testResults
    )}
    if [ '${builtins.toString (builtins.all (result: result.exists) testResults)}' != '1' ]; then exit 1; fi

    touch $out
  '';
in
pkgs.runCommandNoCC "run-tests" { } ''
  sh ${testScript}
''

