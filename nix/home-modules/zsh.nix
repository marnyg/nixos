{ pkgs, lib, config, ... }:
with lib;
{
  options.modules.zsh = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.zsh.enable {
    #programs.starship = {
    #  enable = true;
    #  enableZshIntegration = true;
    #};

    modules.fzf.enable = true;

    programs.eza = {
      enable = true;
      enableZshIntegration = true;
      git = true;
      icons = "auto";
      extraOptions = [ "-a" ];
    };
    programs.atuin = {
      enable = true;
      enableZshIntegration = true;
      flags = [ "--disable-up-arrow" ];
    };

    programs.zsh = {
      enable = true;

      # directory to put config files in
      dotDir = ".config/zsh";

      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      # .zshrc
      initExtra = ''
        PROMPT="%F{blue}%m %~%b "$'\n'"%(?.%F{green}%Bλ%b |.%F{red}?) %f"
        export PASSWORD_STORE_DIR="$XDG_DATA_HOME/password-store";
        export ZK_NOTEBOOK_DIR="~/stuff/notes";
        export DIRENV_LOG_FORMAT="";
        edir() { tar -cz $1 | age -p > $1.tar.gz.age && rm -rf $1 &>/dev/null && echo "$1 encrypted" }
        ddir() { age -d $1 | tar -xz && rm -rf $1 &>/dev/null && echo "$1 decrypted" }
        fzf-cd-widget() {
          local cmd="''${FZF_ALT_C_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
            -o -type d -print 2> /dev/null | cut -b3-"}"
          setopt localoptions pipefail no_aliases 2> /dev/null
          local dir="$(eval "$cmd" | FZF_DEFAULT_OPTS="--height ''${FZF_TMUX_HEIGHT:-40%} --reverse --scheme=path --bind=ctrl-z:ignore ''${FZF_DEFAULT_OPTS-} ''${FZF_ALT_C_OPTS-}" $(__fzfcmd) +m)"
          if [[ -z "$dir" ]]; then
            zle redisplay
            return 0
          fi
          zle push-line # Clear buffer. Auto-restored on next prompt.
          BUFFER="builtin pushd -- ''${(q)dir}"
          zle accept-line
          local ret=$?
          unset dir # ensure this doesn't end up appearing in prompt expansion
          zle reset-prompt
          return $ret
        }
        zle     -N             fzf-cd-widget

        bindkey -M viins '\C-@' accept-line
        bindkey -M viins '^A'   beginning-of-line  
        bindkey -M viins '^E'   end-of-line        
        bindkey -M viins '^F'   fzf-cd-widget
        bindkey -s "^P" 'popd^M'

        KEYTIMEOUT=1


        function col() { eval "awk '{ print \$$1 }'"; }
        function skip() { tail -n +$(($1 + 1)); }
        function take() { head -n $1; }
        function up() { cd $(eval printf '../'%.0s {1..$1}); }
        function mkcd() { mkdir -p "$1" && cd "$1" && pwd; }
        function ::() { sed "$ s/\n$//" | xargs -I_ --; }
        function gcm() { git commit -m "$*" }

        zvm_bindkey vicmd '^e' accept-line 

        #export ANTHROPIC_API_KEY=$(cat ${config.age.secrets.claudeToken.path});
        export ANTHROPIC_API_KEY=$(cat /run/agenix/claudeToken);

        eval "$(${pkgs.starship}/bin/starship init zsh)"
      '';

      # Tweak settings for history
      history = {
        path = "$HOME/.cache/zsh_history";
      };

      # Set some aliases
      shellAliases = {
        "::" = ''sed "$ s/\n$//" | xargs -I_ --'';
        c = "clear";
        chx = "chmod +x";
        v = "nvim";
        mkdir = "mkdir -vp";
        rm = "rm -rifv";
        mv = "mv -iv";
        cp = "cp -riv";
        cdn = "cd ~/git/nixos";
        cat = "${pkgs.bat}/bin/bat --paging=never --style=plain";
        tree = "${pkgs.eza}/bin/eza --tree --icons";
        du = "${pkgs.du-dust}/bin/dust";
        dua = "${pkgs.dua}/bin/dua";
        df = "${pkgs.duf}/bin/duf";
        lf = "${pkgs.yazi}/bin/yazi";

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
        gi = "${pkgs.lazygit}/bin/lazygit";
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

      # Source all plugins, nix-style
      plugins = [
        {
          name = "vi-mode";
          src = pkgs.zsh-vi-mode;
          file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
        }
        {
          name = "zsh-abbr";
          src = pkgs.fetchFromGitHub {
            owner = "olets";
            repo = "zsh-abbr";
            rev = "03328a1ad501fa126a49590d8bde675edfdf1385";
            sha256 = "sha256-utn1sJr5+jW7hD9oCj/TzPcaWNCsm7fExiTUuGWNpdI=";
          };
        }
      ];

    };
  };
}
