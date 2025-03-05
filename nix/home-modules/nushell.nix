{ lib, config, pkgs, ... }:
with lib;
{
  options.modules.nushell = {
    enable = mkOption { type = types.bool; default = false; };
    fontsize = mkOption { type = types.number; default = 12; };
  };

  config = mkIf config.modules.nushell.enable {
    home.shell.enableNushellIntegration = true;

    # home.packages= [pkgs.bat];
    programs.bat.enable = true;
    programs.bat.config = {
      paging = "never";
      style = "plain";
    };

    programs.nushell = {
      enable = true;

      configFile.text = ''
        $env.config.edit_mode = 'vi'
        $env.config.show_banner = false
        ${lib.optionalString (config.age ? secrets && config.age.secrets ? claudeToken) ''
          $env.ANTHROPIC_API_KEY = open "${config.age.secrets.claudeToken.path}" | str trim
          $env.OPENROUTER_API_KEY = open "${config.age.secrets.openrouterToken.path}" | str trim
        ''}


        let carapace_completer = {|spans|
            carapace $spans.0 nushell ...$spans | from json
        }

        $env.config = {
            completions: {
                case_sensitive: false # case-sensitive completions
                quick: true    # set to false to prevent auto-selecting completions
                partial: true    # set to false to prevent partial filling of the prompt
                algorithm: "fuzzy"    # prefix or fuzzy
                external: {
                    # set to false to prevent nushell looking into $env.PATH to find more suggestions
                    enable: true 
                    # set to lower can improve completion performance at the cost of omitting some options
                    max_results: 100 
                    completer: $carapace_completer # check 'carapace_completer' 
                }
            }
        }



        def gcm [...message: string] {
            git commit -m ($message | str join " ")
        }

        alias c = clear;
        alias chx = chmod +x;
        alias v = nvim;
        alias mkdir = mkdir -v;
        alias rm = rm -rifv;
        alias mv = mv -iv;
        alias cp = cp -riv;
        alias cdn = cd ~/git/nixos;
        alias cat = bat;
        alias tree = ${pkgs.eza}/bin/eza --tree --icons;
        alias du = ${pkgs.du-dust}/bin/dust;
        alias dua = ${pkgs.dua}/bin/dua;
        alias df = ${pkgs.duf}/bin/duf;
        alias lf = ${pkgs.yazi}/bin/yazi;

        alias g = git
        alias gm = git merge
        alias gmv = git mv
        alias grm = git rm
        alias gs = git status
        alias gss = git status -s
        alias gl = git pull
        alias gc = git commit
        alias ga = git add
        alias gai = git add -i
        alias gi = ${pkgs.lazygit}/bin/lazygit
        alias gap = git add -p
        alias gaa = git add -A
        alias gpr = git pull --rebase
        #alias gfrb = git fetch; git rebase
        alias gp = git push
        alias gcount = git shortlog -sn
        alias gco = git checkout
        alias gsl = git shortlog -sn
        alias gwc = git whatchanged
        alias gcaa = git commit -a --amend -C HEAD
        alias gpm = git push origin main
        alias gd = git diff
        alias gb = git branch
        alias gt = git tag
        #alias gaugcm = git add -u; gcm
        #alias gfp = git commit --amend --no-edit; git push --force-with-lease
      '';

    };


    programs.carapace.enable = true;
    # programs.carapace.enableNushellIntegration = true;

    programs.starship.enable = true;
    # programs.starship.enableNushellIntegration = true;
  };
}
