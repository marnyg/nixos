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
    programs.zoxide.enable = true;
    programs.zoxide.enableNushellIntegration = true;

    programs.nushell = {
      enable = true;

      configFile.text = ''
        $env.config.edit_mode = 'vi'
        $env.config.show_banner = false
        ${lib.optionalString (config.age ? secrets && config.age.secrets ? claudeToken) ''
          $env.ANTHROPIC_API_KEY = open "${config.age.secrets.claudeToken.path}" | str trim
          $env.OPENROUTER_API_KEY = open "${config.age.secrets.openrouterToken.path}" | str trim
          $env.OPENAI_API_KEY = open "${config.age.secrets.openrouterToken.path}" | str trim
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
        # alias lf = ${pkgs.yazi}/bin/yazi;

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

      envFile.text = lib.optionalString (pkgs.system == "aarch64-darwin") ''
        $env.__NIX_DARWIN_SET_ENVIRONMENT_DONE = 1 
        $env.PATH = [
            $"($env.HOME)/.nix-profile/bin"
            $"/etc/profiles/per-user/($env.USER)/bin"
            "/run/current-system/sw/bin"
            "/nix/var/nix/profiles/default/bin"
            "/usr/local/bin"
            "/usr/bin"
            "/usr/sbin"
            "/bin"
            "/sbin"
        ]
        $env.EDITOR = "NVIM"
        $env.NIX_PATH = [
            $"darwin-config=($env.HOME)/.nixpkgs/darwin-configuration.nix"
            "/nix/var/nix/profiles/per-user/root/channels"
        ]
        $env.NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt"
        $env.PAGER = "less -R"
        $env.TERMINFO_DIRS = [
            $"($env.HOME)/.nix-profile/share/terminfo"
            $"/etc/profiles/per-user/($env.USER)/share/terminfo"
            "/run/current-system/sw/share/terminfo"
            "/nix/var/nix/profiles/default/share/terminfo"
            "/usr/share/terminfo"
        ]
        $env.XDG_CONFIG_DIRS = [
            $"($env.HOME)/.nix-profile/etc/xdg"
            $"/etc/profiles/per-user/($env.USER)/etc/xdg"
            "/run/current-system/sw/etc/xdg"
            "/nix/var/nix/profiles/default/etc/xdg"
        ]
        $env.XDG_DATA_DIRS = [
            $"($env.HOME)/.nix-profile/share"
            $"/etc/profiles/per-user/($env.USER)/share"
            "/run/current-system/sw/share"
            "/nix/var/nix/profiles/default/share"
        ]
        $env.TERM = $env.TERM
        $env.NIX_USER_PROFILE_DIR = $"/nix/var/nix/profiles/per-user/($env.USER)"
        $env.NIX_PROFILES = [
            "/nix/var/nix/profiles/default"
            "/run/current-system/sw"
            $"/etc/profiles/per-user/($env.USER)"
            $"($env.HOME)/.nix-profile"
        ]

        if ($"($env.HOME)/.nix-defexpr/channels" | path exists) {
            $env.NIX_PATH = ($env.PATH | split row (char esep) | append $"($env.HOME)/.nix-defexpr/channels")
        }

        if (false in (ls -l `/nix/var/nix`| where type == dir | where name == "/nix/var/nix/db" | get mode | str contains "w")) {
            $env.NIX_REMOTE = "daemon"
        }
      '';
    };


    programs.carapace.enable = true;
    # programs.carapace.enableNushellIntegration = true;

    programs.starship.enable = true;
    # programs.starship.enableNushellIntegration = true;
  };
}
