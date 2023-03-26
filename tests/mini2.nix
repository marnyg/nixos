pkgs: {
  # NixOS tests are run inside a virtual machine, and here we specify system of the machine.
  name = "mini system test";
  nodes.mini = { pkgs, lib, ... }:
    {
      sound.enable = true; # needed for the factl test, /dev/snd/* exists without them but udev doesn't care then
    };

  testScript = ''
    start_all()
    mini.wait_for_unit("alsa-store")

    assert True, "test runnig works"
  '';
}
