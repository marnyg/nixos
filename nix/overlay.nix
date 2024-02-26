{ }
#{
#  perSystem = { system,inputs, ... }: {
#    _module.args.pkgs = import inputs.nixpkgs {
#      inherit system;
#      overlays = [
#  #      inputs.foo.overlays.default
#        (final: prev: {
#          # ... things you need to patch ...
#        })
#      ];
#      config = { };
#    };
#  };
#}
