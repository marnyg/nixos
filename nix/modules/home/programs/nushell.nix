# Nushell configuration module
# Note: Nushell is experimental and not the primary shell
# Consider using Fish (default) or Zsh instead
{ lib, config, pkgs, ... }:
with lib;
{
  options.modules.my.nushell = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Nushell - experimental shell (consider using Fish instead)";
    };
  };

  config = mkIf config.modules.my.nushell.enable {
    # Enable shared shell configuration for common aliases and tools
    modules.my.sharedShellConfig.enable = true;

    # Nushell-specific integrations
    programs.zoxide.enableNushellIntegration = true;
    programs.starship.enableNushellIntegration = true;
    programs.carapace.enableNushellIntegration = true;

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



        # Nushell-specific function for git commit with message
        def gcm [...message: string] {
            git commit -m ($message | str join " ")
        }

        # Import aliases from sharedShellConfig (these are handled by home.shellAliases)
        # Only define Nushell-specific aliases here
        alias gi = ${pkgs.lazygit}/bin/lazygit
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


    # Carapace for completions (handled by sharedShellConfig if needed)
    programs.carapace.enable = true;
  };
}
