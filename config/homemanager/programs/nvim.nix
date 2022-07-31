{ pkgs, ... }:
{
  home.file = {
    ".config/nvim".source = pkgs.fetchFromGitHub {
      owner = "marnyg";
      repo = "nvim-conf";
      rev = "8861e72";
      sha256 = "jZixvObvw2WX+qigV+GKe4z+UlhM8T3kJvrV9E8qE6w=";
    };
  };
}
