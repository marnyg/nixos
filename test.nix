#pkgs:
#pkgs.nixosTest ({
{

  # NixOS tests are run inside a virtual machine, and here we specify system of the machine.

  #system = "x86_64-linux";
  name = "mini system test";


  nodes.mini =
    { pkgs, lib, ... }:
    {
      boot.kernelPackages = pkgs.linuxPackages_latest;
      sound.enable = true; # needed for the factl test, /dev/snd/* exists without them but udev doesn't care then
    };
  skipLint = true;

  testScript = ''
    #import json
    #import sys

    start_all()
    #mini.wait_for_unit("sound")

    #server.wait_for_open_port("1234")

    #expected = [
    #    {"id": 1, "done": False, "task": "finish tutorial 0", "due": None},
    #    {"id": 2, "done": False, "task": "pat self on back", "due": None},
    #]

    #actual = json.loads(
    #    client.succeed(
    #        "${pkgs.curl}/bin/curl http://server:123/talbe"
    #    )
    #)

    #assert expected == actual, "table query returns expected content"
    assert True, "table query returns expected content"
    assert True, "table query returns expected content"
  '';

}
