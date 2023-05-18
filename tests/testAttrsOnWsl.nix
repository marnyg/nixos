{ pkgs, self }:
let
  lib = pkgs.lib;

  getNestedAttr = attrList: obj:
    lib.attrByPath attrList (throw "${builtins.concatStringsSep "." attrList} does not exist") obj;

  hasAttr = str: obj:
    (builtins.tryEval (getNestedAttr (builtins.filter (x: x != [ ]) (builtins.split "\\." str)) obj)).success;

  checkAttr = str: obj:
    let exists = hasAttr str obj; in
    { exists = exists; description = if exists then "${str} exists" else "${str} does not exist"; };

  os= self.nixosConfigurations.wsl2;

  attrs = [
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

    # nex part
    #  check if value equals true "config.home-manager.users.mar.services.dunst.enable"
  ];
  testResults = builtins.map (attr: checkAttr attr os) attrs;


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



## Define the configuration
#myConfiguration = {
#  imports = [ ./configuration.nix ]; # Your actual configuration
#};
## Evaluate the configuration
#config = (lib.evalModules { modules = [ myConfiguration ]; }).config;
