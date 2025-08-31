{ pkgs, lib, config, ... }:
with lib;
{
  options.modules.sharedShellConfig = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable shared shell configuration and aliases.
        
        This module provides common aliases, enhanced CLI tools (bat, eza, dust, etc.),
        shell integrations (atuin, starship, zoxide), and Git aliases that work
        across both Zsh and Fish shells.
      '';
    };
  };

  config = mkIf config.modules.sharedShellConfig.enable {
    # Shared CLI tools and configuration
    programs.eza = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      git = true;
      icons = "auto";
      extraOptions = [ "-a" ];
    };

    programs.atuin = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      flags = [ "--disable-up-arrow" ];
      settings = {
        inline_height = 0;
        style = "compact";
      };
    };

    programs.starship.enable = true;
    programs.zoxide.enable = true;
    programs.fzf.enable = true;

    # Shared environment variables
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PASSWORD_STORE_DIR = "$XDG_DATA_HOME/password-store";
      ZK_NOTEBOOK_DIR = "~/stuff/notes";
      DIRENV_LOG_FORMAT = "";
    };

    # Shared aliases
    home.shellAliases = {
      # Basic commands
      c = "clear";
      chx = "chmod +x";
      v = "nvim";
      mkdir = "mkdir -vp";
      rm = "rm -rifv";
      mv = "mv -iv";
      cp = "cp -riv";
      cdn = "cd ~/git/nixos";

      # Enhanced CLI tools
      cat = "${pkgs.bat}/bin/bat --paging=never --style=plain";
      tree = "${pkgs.eza}/bin/eza --tree --icons";
      du = "${pkgs.du-dust}/bin/dust";
      dua = "${pkgs.dua}/bin/dua";
      df = "${pkgs.duf}/bin/duf";
      lf = "${pkgs.yazi}/bin/yazi";

      # Git aliases
      g = "git";
      gm = "git merge";
      gmv = "git mv";
      grm = "git rm";
      gs = "git status";
      gss = "git status -s";
      gl = "git pull";
      gc = "git commit";
      ga = "git add";
      gai = "git add -i";
      gap = "git add -p";
      gaa = "git add -A";
      gpr = "git pull --rebase";
      gfrb = "git fetch && git rebase";
      gp = "git push";
      gcount = "git shortlog -sn";
      gco = "git checkout";
      gsl = "git shortlog -sn";
      gwc = "git whatchanged";
      gcaa = "git commit -a --amend -C HEAD";
      gpm = "git push origin main";
      gd = "git diff";
      gb = "git branch";
      gt = "git tag";
      gaugcm = "git add -u && gcm";
      gfp = "git commit --amend --no-edit && git push --force-with-lease";

      # Utility aliases
      hist = "tmux capture-pane -pS - | ${pkgs.fzf}/bin/fzf";
      fixSsh = "echo 'UPDATESTARTUPTTY' | gpg-connect-agent > /dev/null 2>&1";
    };
  };
}
