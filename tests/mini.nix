pkgs: {
  # NixOS tests are run inside a virtual machine, and here we specify system of the machine.
  name = "mini system test";
  nodes.mini = { pkgs, lib, ... }:
    { };

  testScript = ''
    assert True, "test runnig works"
  '';
}
