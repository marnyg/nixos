pkgs:
{
  programs.git = {
    enable = true;
    userName = "marius";
    userEmail = "marnyg@proton.me";
    delta.enable = true;
    extraConfig = {
      init = { defaultBranch = "main"; };
      pull = {
        rebase=true;
        ff= "only";
      };
    };
  };
}
