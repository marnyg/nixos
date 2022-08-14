{ pkgs, config, ... }:
{
#  home.file = {
#    ".config/nvim".source = pkgs.fetchFromGitHub {
#      owner = "marnyg";
#      repo = "nvim-conf";
#      rev = "test";
#      # rev = "8861e72";
#      # sha256 = "jZixvObvw2WX+qigV+GKe4z+UlhM8T3kJvrV9E8qE6w=";
#      sha256 = "5h3mtocJiU04MjEVmgYk10Feb4GbOsoSubQWCbwfkFo=";
#    };
#  };



  # home.file = {
  #   ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "/home/mar/git/nvim-conf";
  # };



  # home.file = {
  #   ".config/nvim".source = pkgs.fetchgit {
  #     url = "file:///home/mar/git/nvim-conf";
  #     rev = "test";
  #     sha256 = "4R2X30GuERrGdjH7kg4d3MXmYaiK40G+zkAkbKZkf2E=";
  #   };
  # };

}
