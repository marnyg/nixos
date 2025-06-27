{ pkgs, lib, config, ... }:
with lib;
{
  options.modules.fish.enable = mkOption { type = types.bool; default = false; };

  config = mkIf config.modules.fish.enable {
    home.shell.enableFishIntegration = true;

    programs.zoxide.enable = true;
    programs.starship.enable = true;
    programs.fzf.enable = true;
    programs.atuin = {
      enable = true;
      flags = [ "--disable-up-arrow" ];
      settings = {
        inline_height = 0;
        style = "compact";
      };
    };
    programs.eza = {
      enable = true;
      enableZshIntegration = true;
      git = true;
      icons = "auto";
    };



    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        fish_vi_key_bindings
        set -gx ANTHROPIC_API_KEY $(cat ${config.age.secrets.claudeToken.path})
        set -gx OPENROUTER_API_KEY $(cat ${config.age.secrets.openrouterToken.path})
        set -gx OPENAI_API_KEY $(cat ${config.age.secrets.openrouterToken.path})
        set -gx EDITOR nvim
      '';
      functions = {
        gcm = ''
          git commit -m "$argv"
        '';
      };
      shellAliases = {
        c = "clear";
        chx = "chmod +x";
        v = "nvim";
        mkdir = "mkdir -vp";
        rm = "rm -rifv";
        mv = "mv -iv";
        cp = "cp -riv";
        cdn = "cd ~/git/nixos";
        cat = "${pkgs.bat}/bin/bat --paging=never --style=plain";
        #tree = "${pkgs.eza}/bin/eza --tree --icons";
        du = "${pkgs.du-dust}/bin/dust";
        dua = "${pkgs.dua}/bin/dua";
        df = "${pkgs.duf}/bin/duf";
        lf = "${pkgs.yazi}/bin/yazi";

        g = "git";
        gm = "git merge";
        gmv = "git mv";
        grm = "git rm";
        gs = "git status";
        # gss = "git status -s";
        # gl = "git pull";
        # gc = "git commit";
        ga = "git add";
        gai = "git add -i";
        gi = "gitui";
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

        hist = "tmux capture-pane -pS - | ${pkgs.fzf}/bin/fzf";
        fixSsh = "echo 'UPDATESTARTUPTTY' | gpg-connect-agent > /dev/null 2>&1";
      };

      plugins = [
        # pkgs.fishPlugins.bang-bang
        {
          name = "bang-bang";
          src = pkgs.fetchFromGitHub {
            owner = "oh-my-fish";
            repo = "plugin-bang-bang";
            rev = "master";
            sha256 = "sha256-oPPCtFN2DPuM//c48SXb4TrFRjJtccg0YPXcAo0Lxq0=";
          };
        }
      ];

      # initExtra = ''
      #   function col() { eval "awk '{ print \$$1 }'"; }
      #   function skip() { tail -n +$(($1 + 1)); }
      #   function take() { head -n $1; }
      #   function up() { cd $(eval printf '../'%.0s {1..$1}); }
      #   function mkcd() { mkdir -p "$1" && cd "$1" && pwd; }
      #   function ::() { sed "$ s/\n$//" | xargs -I_ --; }
      #   function gcm() { git commit -m "$*" }
      #
      #   export ANTHROPIC_API_KEY=$(cat ${config.age.secrets.claudeToken.path});
      #   export OPENROUTER_API_KEY=$(cat ${config.age.secrets.openrouterToken.path});
      #   export OPENAI_API_KEY=$(cat ${config.age.secrets.openrouterToken.path});
      # '';
    };
  };
}
