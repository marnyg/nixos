pkgs:
{
  programs.git = {
    enable = true;
    userName = "marius";
    userEmail = "marnyg@proton.me";
    extraConfig = {
      init = { defaultBranch = "main"; };
    };
  };
}