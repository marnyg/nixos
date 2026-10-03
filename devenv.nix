{ pkgs, lib, ... }:

let
  # beads (`bd`) git hooks, declared here instead of via `bd hooks install`.
  # `bd hooks install` sets core.hooksPath=.beads/hooks and copies the
  # pre-commit-generated scripts there, which hardcodes store paths that
  # break on the next nixpkgs bump and blocks git-hooks.nix from
  # reinstalling. Keeping git-hooks.nix as the single hook owner avoids that.
  beadsHook = stage: {
    enable = true;
    name = "beads ${stage}";
    entry = "${pkgs.beads}/bin/bd hooks run ${stage}";
    stages = [ stage ];
    pass_filenames = false;
    always_run = true;
  };
in
{
  # Development packages
  packages = with pkgs; [ worktrunk ];

  # Shell hook
  enterShell = ''
    # Worktrunk (`wt`) shell integration — devenv spawns bash, so the
    # fish-side integration from the home-manager worktrunk module doesn't
    # apply here. Without this, `wt remove` can't cd out of the doomed
    # worktree before deletion, leaving the shell stranded.
    if command -v wt >/dev/null 2>&1; then
        eval "$(${pkgs.worktrunk}/bin/wt config shell init bash)"
    fi

    echo "🚀 NixOS Development Environment (via devenv)"
    echo "Available hosts: wsl, desktop, laptop, mac"
    echo ""
    echo "Commands:"
    echo "  nix build .#nixosConfigurations.<host>.config.system.build.toplevel"
    echo "  nixos-rebuild switch --flake .#<host> (on NixOS)"
    echo "  darwin-rebuild switch --flake .#mac (on macOS)"
    echo "  nix run .#<host> (to test VM)"
    echo ""
  '';

  # Pre-commit hooks configuration
  git-hooks.hooks = {
    nixpkgs-fmt.enable = true;
    deadnix.enable = true;
    nil.enable = true;
    # Manual-only: nixvim keymap descriptions use which-key bracket style
    # ("[D]efinition", "[S]earch"), which typos tokenises as misspellings.
    # Run on demand: pre-commit run typos --all-files --hook-stage manual
    typos = {
      enable = true;
      settings.ignored-words = [ "noice" ];
      stages = [ "manual" ];
    };
    commitizen.enable = true;
    yamlfmt.enable = true;
  } // lib.listToAttrs (map
    (stage: lib.nameValuePair "beads-${stage}" (beadsHook stage))
    [ "pre-commit" "prepare-commit-msg" "post-checkout" "post-merge" "pre-push" ]);

  # Languages support (add as needed for specific project development)
  languages = {
    nix.enable = true;
  };

  # Development-specific tools can be added here:
  # - Scripts for automation
  # - Task runners
  # - Language servers and tools
  # - Local development processes
  # - Services (databases, etc.)
  # - Containers for testing
}
