pkgs:
{
  programs.git = {
    enable = true;
    userName = "marius";
    userEmail = "marnyg@proton.me";
    delta.enable = true;
    #lsf.enabled =true;
    aliases= { 
      co = "checkout"; 
      b = "branch"; 
      ps = "push"; 
      pl = "pull"; 
      c = "commit"; 
      cm = "commit -m"; 
      a = "add"; 
      s = "status"; 
      lg = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all";
      lg2 = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all";
    }; 
    extraConfig = {
      init = { defaultBranch = "main"; };
      pull = {
        rebase=true;
        ff= "only";
      };
    };
  };
}
