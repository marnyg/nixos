{ lib, ... }:
{
  options.flake-parts.userRegistry = lib.mkOption {
    type = lib.types.attrs;
    default = { };
    description = "Internal user registry";
  };

  config.flake-parts.userRegistry = {
    mar = {
      metadata = import ./mar/default.nix;
      systemConfig = ./mar/system.nix;
      homeConfig = ./mar/home.nix;
    };
    testUser = {
      metadata = import ./testUser/default.nix;
      systemConfig = ./testUser/system.nix;
      homeConfig = ./testUser/home.nix;
    };
  };
}

