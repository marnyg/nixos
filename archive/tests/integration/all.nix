_pkgs: {
  # NixOS tests are run inside a virtual machine, and here we specify system of the machine.

  #system = "x86_64-linux";
  name = "mini system test";


  nodes.mini =
    { pkgs, ... }:
    {
      boot.kernelPackages = pkgs.linuxPackages_latest;
      sound.enable = true; # needed for the factl test, /dev/snd/* exists without them but udev doesn't care then
    };
  skipLint = true;

  testScript = ''
    start_all()
    assert False, "false"
  '';
}
