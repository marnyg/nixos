# Custom configurations:
#  (should trigger automatically)
# [ both primary external ]
#
# Default configurations:
#  (can be used with unknown displays)
# [ horizontal vertical common clone-largest ]
# manulay trigger by running `autorandr default`
# get finger print with `autorandr --fingerprint`
{ pkgs, lib, config, ... }:
with lib;
{
  options.modules.autorandr = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.autorandr.enable {


    # systemd.services.my-autorandr = {
    #   description = "...";
    #   serviceConfig.PassEnvironment = "DISPLAY";
    #   script = with pkgs; "${autorandr} default";
    #   wantedBy = [ "multi-user.target" ]; # starts after login
    # };

    programs.autorandr = {
      enable = true;
      profiles = {
        default = {
          config = {
            "DVI-D-1" = {
              enable = true;
              mode = "3840x2160";
              primary = true;
              position = "1080x1080";
              rate = "30.00";
              # rate = "27.26";
              # crtc = 0;
            };
            "DVI-I-1" = {
              enable = true;
              mode = "1920x1080";
              primary = false;
              position = "1880x0";
              rate = "60.00";
              # crtc = 1;
            };
            "HDMI-1" = {
              enable = true;
              mode = "1920x1080";
              primary = false;
              position = "0x819";
              rate = "60.00";
              rotate = "right";
            };
          };
          fingerprint = {
            "DVI-D-1" =
              "00ffffffffffff00410ce1082446000022190103805831782af63da3554e9e270d474abd4b00d1c081808140950f9500b30081c00101a3660030f2701f80b0588a006ee53100001a565e00a0a0a02950302035006ee53100001e000000fc0050484c2042444d343036350a20000000fd0017501e631e000a20202020202001de02032af14f010203050607101112131415161f0423090707830100006d030c001000003c200060010203023a80d072382d40102c96806ee531000018ef5100a0f0701980302035006ee53100001aa3660030f2701f80b0588a006ee53100001a7d3900a080381f4030203a006ee53100001a0000000000000000000000000039";
            "DVI-I-1" =
              "00ffffffffffff000469c42701010101331a0103803c2278ea53a5a756529c26115054afef808100814081809500b3008bc0a9400101023a801871382d40582c450056502100001e000000fd00324c1e530f000a202020202020000000fc0056433237390a20202020202020000000ff0047434c4d52533030363932350a00f7";
            "HDMI-1" =
              "00ffffffffffff004c2d200d37505a5a2b1c010380341d782a9315a655519c27115054bfef80714f81c0810081809500a9c0b3000101023a801871382d40582c450009252100001e000000fd00324b1e5111000a202020202020000000fc00533234463335300a2020202020000000ff0048345a4b4130343737390a202001bf020311b14690041f13120365030c001000011d00bc52d01e20b828554009252100001e8c0ad090204031200c4055000925210000188c0ad08a20e02d10103e9600092521000018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000051";
          };
        };
        # external = {
        #   config = {
        #     "${cfg.display2.name}" = {
        #       enable = true;
        #       mode = "1920x1080";
        #       position = "0x0";
        #       primary = true;
        #       rate = "60.00";
        #       crtc = 0;
        #     };
        #   };
        #   fingerprint = {
        #     "${cfg.display1.name}" = "${cfg.display1.fp}";
        #     "${cfg.display2.name}" = "${cfg.display2.fp}";
        #   };
        # };
        # primary = {
        #   config = {
        #     "${cfg.display1.name}" = {
        #       enable = true;
        #       mode = "1920x1080";
        #       position = "0x0";
        #       primary = true;
        #       rate = "60.00";
        #       crtc = 0;
        #     };
        #   };
        #   fingerprint = {
        #     "${cfg.display1.name}" = "${cfg.display1.fp}";
        #   };
        # };
      };
    };
  };
}

# User configuration for autorandr
# helped by modular dotfiles
#   [[https://github.com/dmarcoux/dotfiles-nixos/blob/d784c35f0b2468e1801bf60fde12211eef5485ba/hosts/laptop-work/autorandr.nix]]
# and sample config in home-manager tests
#   [[https://github.com/nix-community/home-manager/blob/ef4370bedc9e196aa4ca8192c6ceaf34dca589ee/tests/modules/programs/autorandr/basic-configuration.nix]]
# documentation on writing modules:
#   [[https://nixos.org/manual/nixos/stable/#sec-writing-modules]]
