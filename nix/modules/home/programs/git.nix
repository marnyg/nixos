{ pkgs, lib, config, inputs, ... }:
with lib;
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
    # programs.git-credential-oauth.enable = true;
    programs.gh = {
      enable = true;
      gitCredentialHelper.enable = true;
    };
    programs.gh-dash.enable = true;
    programs.mergiraf.enable = true;

    # Difftastic configuration (moved from programs.git)
    programs.difftastic = {
      enable = true;
      git.enable = true; # Explicitly enable git integration
    };

    programs.git = {
      package = pkgs.gitFull;
      enable = true;
      ignores = [
        "**/.envrc"
        "**/scratch"
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
      package = inputs.nixpkgs-old.legacyPackages.x86_64-linux.gitui;
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
