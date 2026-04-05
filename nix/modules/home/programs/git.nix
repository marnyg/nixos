{ pkgs, lib, config, ... }:
with lib;
let
  git-bare-clone = pkgs.writeShellApplication {
    name = "git-bare-clone";
    runtimeInputs = with pkgs; [ git coreutils ];
    text = ''
      url_decode() {
        local input="$1" result=""
        while [[ "$input" =~ (%)([0-9A-Fa-f][0-9A-Fa-f]) ]]; do
          result+="''${input%%"%"*}"
          printf -v decoded '%b' "\\x''${BASH_REMATCH[2]}"
          result+="$decoded"
          input="''${input#*"''${BASH_REMATCH[0]}"}"
        done
        result+="$input"
        printf '%s' "$result"
      }

      derive_dirname() {
        local url="$1"
        url="''${url%/}"
        url="''${url%.git}"
        local basename
        basename="''${url##*/}"
        basename="$(url_decode "$basename")"
        basename="''${basename//[[:space:]\/\\:%+]/_}"
        while [[ "$basename" == *__* ]]; do basename="''${basename//__/_}"; done
        basename="''${basename#_}"
        basename="''${basename%_}"
        echo "$basename"
      }

      if [[ $# -lt 1 ]]; then
        echo "Usage: git-bare-clone <repo-url> [directory]" >&2
        exit 1
      fi

      REPO_URL="$1"
      TARGET_DIR="''${2:-$(derive_dirname "$REPO_URL")}"

      if [[ -z "$TARGET_DIR" ]]; then
        echo "Error: Could not derive directory name from URL" >&2
        exit 1
      fi

      if [[ -d "$TARGET_DIR" ]]; then
        echo "Error: Directory '$TARGET_DIR' already exists" >&2
        exit 1
      fi

      echo "Bare-cloning into $TARGET_DIR/.git ..."
      git clone --bare "$REPO_URL" "$TARGET_DIR/.git"

      cd "$TARGET_DIR"
      git config core.bare true
      git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"

      echo "Fetching remote branches..."
      git fetch origin

      echo "Done. Ready for: git worktree add ./<dir> <branch>"
    '';
  };
in
{
  options.modules.my.git = {
    enable = mkEnableOption ''
      personal Git configuration.
      
      Configures Git with personal settings, aliases, and integrations.
      Includes GitHub CLI (gh), GitUI, and personal user information.
      Sets up useful Git aliases and configuration for daily development work
    '';
  };

  config = mkIf config.modules.my.git.enable {
    home.packages = [ git-bare-clone ];

    # programs.git-credential-oauth.enable = true;
    programs.gh = {
      enable = true;
      gitCredentialHelper.enable = true;
    };
    programs.gh-dash.enable = true;
    programs.mergiraf.enable = true;
    programs.mergiraf.enableGitIntegration = true;

    # Difftastic configuration (moved from programs.git)
    programs.difftastic = {
      enable = true;
      git.enable = true; # Explicitly enable git integration
    };

    programs.git = {
      package = pkgs.gitFull;
      enable = true;
      signing.format = null;
      ignores = [
        "**/.envrc"
        "**/scratch"
        ".envrc.local"
        "${config.home.homeDirectory}/git/sendra/**/flake.*"
        "${config.home.homeDirectory}/git/wellstarter/**/flake.*"
      ];
      #lsf.enabled =true;
      settings = {
        # User configuration (previously userName and userEmail)
        user = {
          name = "marius";
          email = "marnyg@proton.me";
        };

        # Aliases (previously programs.git.aliases)
        alias = {
          co = "checkout";
          b = "branch";
          ps = "push";
          pl = "pull";
          c = "commit";
          cm = "commit -m";
          a = "add";
          ai = "add -i";
          s = "status";
          undo = "reset HEAD~";
          lg =
            "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all";
          lg2 =
            "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all";
        };

        # Extra configuration (previously programs.git.extraConfig)
        init = {
          defaultBranch = "main";
        };
        # credential.helper = [
        #   "${pkgs.git-credential-manager}/bin/git-credential-manager"
        #   "cache --timeout 72000"
        # ];
        credential.credentialStore = "cache";
        push.autoSetupRemote = true;
        core.editor = "nvim";
        pull.rebase = true;
        merge.conflictStyle = "diff3"; # Shows common ancestor for better conflict resolution
      };
    };
    programs.gitui = {
      enable = true;
      keyConfig = ''
         (
            move_left: Some(( code: Char('h'), modifiers: "")),
            move_right: Some(( code: Char('l'), modifiers: "")),
            move_up: Some(( code: Char('k'), modifiers: "")),
            move_down: Some(( code: Char('j'), modifiers: "")),

            stash_open: Some(( code: Char('l'), modifiers: "")),
            open_help: Some(( code: F(1), modifiers: "")),

            status_reset_item: Some(( code: Char('U'), modifiers: "SHIFT")),
        )
      '';
    };
  };
}
