{
  # NixOS tests are run inside a virtual machine, and here we specify system of the machine.
  name = "mini system test";
  nodes.mini = { ... }:
    { };

  testScript = ''
    assert True, "test running works"
  '';
}
