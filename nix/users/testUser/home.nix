# Home-manager configuration for user 'testUser'
{ ... }:

{
  # Basic home configuration
  home.stateVersion = "23.11";

  # Minimal module selections
  modules = {
    sharedDefaults.enable = true;
    git.enable = false;
    direnv.enable = false;
    tmux.enable = false;
    fzf.enable = false;
    myPackages.enable = false;
    cloneDefaultRepos.enable = false;
  };

  # Basic programs
  programs = {
    bash.enable = true;
    vim.enable = true;
  };

  # Home-specific environment variables
  home.sessionVariables = {
    EDITOR = "vim";
    VISUAL = "vim";
  };
}
