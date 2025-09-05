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
      rm = lib.mkDefault "rm -rifv";
      mv = lib.mkDefault "mv -iv";
      cp = lib.mkDefault "cp -riv";
      cdn = "cd ~/git/nixos";

      # Enhanced CLI tools
      cat = "${pkgs.bat}/bin/bat --paging=never --style=plain";
      tree = "${pkgs.eza}/bin/eza --tree --icons";
      du = "${pkgs.du-dust}/bin/dust";
      dua = "${pkgs.dua}/bin/dua";
      df = "${pkgs.duf}/bin/duf";
      lf = "${pkgs.yazi}/bin/yazi";

      # Git aliases
      g = lib.mkDefault "git";
      gm = lib.mkDefault "git merge";
      gmv = lib.mkDefault "git mv";
      grm = lib.mkDefault "git rm";
      gs = lib.mkDefault "git status";
      gss = lib.mkDefault "git status -s";
      gl = lib.mkDefault "git pull";
      gc = lib.mkDefault "git commit";
      ga = lib.mkDefault "git add";
      gai = lib.mkDefault "git add -i";
      gap = lib.mkDefault "git add -p";
      gaa = lib.mkDefault "git add -A";
      gpr = lib.mkDefault "git pull --rebase";
      gfrb = lib.mkDefault "git fetch && git rebase";
      gp = lib.mkDefault "git push";
      gcount = lib.mkDefault "git shortlog -sn";
      gco = lib.mkDefault "git checkout";
      gsl = lib.mkDefault "git shortlog -sn";
      gwc = lib.mkDefault "git whatchanged";
      gcaa = lib.mkDefault "git commit -a --amend -C HEAD";
      gpm = lib.mkDefault "git push origin main";
      gd = lib.mkDefault "git diff";
      gb = lib.mkDefault "git branch";
      gt = lib.mkDefault "git tag";
      gaugcm = lib.mkDefault "git add -u && gcm";
      gfp = lib.mkDefault "git commit --amend --no-edit && git push --force-with-lease";

      # Utility aliases
      hist = "tmux capture-pane -pS - | ${pkgs.fzf}/bin/fzf";
      fixSsh = "echo 'UPDATESTARTUPTTY' | gpg-connect-agent > /dev/null 2>&1";
    };
  };
}
