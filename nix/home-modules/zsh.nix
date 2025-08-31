{ pkgs, lib, config, ... }:
with lib;
{
  options.modules.zsh = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable Zsh shell with custom configuration.
        
        Automatically enables shared shell configuration, sets up Vi mode,
        custom prompt, useful functions and keybindings, and shell plugins
        including zsh-abbr for abbreviations.
      '';
    };
  };

  config = mkIf config.modules.zsh.enable {
    # Enable shared shell configuration
    modules.sharedShellConfig.enable = true;

    programs.zsh = {
      enable = true;

      # directory to put config files in
      dotDir = ".config/zsh";

      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      # .zshrc
      initContent = ''
        PROMPT="%F{blue}%m %~%b "$'\n'"%(?.%F{green}%Bλ%b |.%F{red}?) %f"
        
        # Shell functions
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

      # ZSH-specific aliases
      shellAliases = {
        "::" = ''sed "$ s/\n$//" | xargs -I_ --'';
        gi = "${pkgs.lazygit}/bin/lazygit";
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
