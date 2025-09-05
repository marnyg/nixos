{ lib, ... }:

let
  # User registry - defines all available users
  # This is the single source of truth for user definitions
  users = {
    mar = ./mar;
    testUser = ./testUser;
  };

  # Helper function to import user configs
  importUser = name: path: {
    inherit name;
    meta = import "${path}/default.nix";
    system = import "${path}/system.nix";
    home = import "${path}/home.nix";
  };

  # Get all available users
  allUsers = lib.mapAttrs (name: path: importUser name path) users;
in
{
  inherit users importUser allUsers;
}
